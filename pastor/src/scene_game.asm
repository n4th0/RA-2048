;;=============================================================================
;; scene_game.asm — Escena de juego: niveles, sistemas, tiempo y pausa
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "text.inc"

DEF PAUSE_ROW     EQU 9
DEF PAUSE_TEXT_X  EQU (SCREEN_W - 5) / 2   ;; "PAUSA" centrado
DEF PAUSE_ADDRESS EQU _SCRN0 + PAUSE_ROW * MAP_STRIDE + PAUSE_TEXT_X

SECTION "Scene game state", WRAM0
current_level:: DS 1         ;; 0 .. NUM_LEVELS - 1
time_left::     DS TIME_BYTES ;; segundos que quedan (BCD, el byte alto primero)
frame_count:    DS 1         ;; frames hasta el siguiente segundo
paused::        DS 1
win_timer:      DS 1         ;; frames de espera tras ganar, antes del mensaje

SECTION "Scene game CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_game_new_game: empieza una partida desde el nivel 1.
scene_game_new_game::
   call score_reset
   xor a
   ld [current_level], a
   ;; sigue en scene_game_enter_level

;;-----------------------------------------------------------------------------
;; scene_game_enter_level: carga current_level y pasa a la escena de juego.
scene_game_enter_level::
   call lcd_off

   ld a, [current_level]    ;; HL = level_table + nivel * LEVEL_ENTRY_SIZE
   ld b, a
   add a
   add b                    ;; A = nivel * 3
   add a                    ;; A = nivel * 6
   ld hl, level_table
   add l
   ld l, a
   adc h
   sub l
   ld h, a

   ld a, [hl+]              ;; mapa
   ld c, a
   ld a, [hl+]
   ld b, a
   ld a, [hl+]              ;; spawns
   ld e, a
   ld a, [hl+]
   ld d, a
   ld a, [hl+]              ;; tiempo (2 bytes BCD)
   ld [time_left], a
   ld a, [hl]
   ld [time_left + 1], a
   ld h, b
   ld l, c                  ;; HL = mapa, DE = spawns

   call scene_game_init

   ld a, FRAMES_PER_SECOND
   ld [frame_count], a
   xor a
   ld [paused], a
   ld a, WIN_DELAY_FRAMES
   ld [win_timer], a

   call hud_init
   call sys_render_flush    ;; marcador a VRAM ya (pantalla apagada)
   call lcd_on
   ld a, SCENE_GAME
   ld [scene_id], a
   ret

ASSERT LEVEL_ENTRY_SIZE == 6 && TIME_BYTES == 2, "scene_game_enter_level multiplica por 6 y copia 2 bytes de tiempo"

;;-----------------------------------------------------------------------------
;; scene_game_init: carga el nivel y crea sus entidades.
;; LLAMAR CON LA PANTALLA APAGADA: pinta el nivel entero en VRAM.
;; 📥 HL = mapa del nivel, DE = su lista de spawns
scene_game_init::
   push de
   call sys_render_reset
   call level_load
   call man_entity_init
   call rng_init            ;; antes de los spawns: reparte sus cooldowns
   pop hl                   ;; HL = spawns

   ;; El primer par es el pastor; los siguientes, ovejas
   ld a, TYPE_SHEPHERD
   ld c, TILE_SHEPHERD
   call spawn_entity
   ret c                    ;; lista vacía o array lleno: nada más que crear
.sheep:
   ld a, TYPE_SHEEP
   ld c, TILE_SHEEP
   call spawn_entity
   jr nc, .sheep

   call sys_corral_init     ;; cuenta ovejas
   jp sys_render_init       ;; dibujarlo todo ya (pantalla apagada)

;;-----------------------------------------------------------------------------
;; spawn_entity: crea una entidad con la siguiente posición de la lista.
;; 📥 HL = puntero a la lista (fila, columna... END_OF_LIST)
;;    A = tipo, C = tile
;; 📤 HL avanzado al siguiente par
;;    carry a 1 si la lista se acabó o el array está lleno (no se creó nada)
;; Modifica: A, F, BC, DE, HL
spawn_entity:
   ld b, a                  ;; B = tipo
   ld a, [hl]
   cp END_OF_LIST
   jr z, .no_more

   push bc
   push hl
   call man_entity_alloc    ;; DE = entidad nueva
   pop hl
   pop bc
   jr c, .array_full

   inc de                   ;; E_TYPE
   ld a, b
   ld [de], a
   inc de                   ;; E_Y
   ld a, [hl+]
   ld [de], a
   inc de                   ;; E_X
   ld a, [hl+]
   ld [de], a
   inc de                   ;; E_TILE
   ld a, c
   ld [de], a
   inc de                   ;; E_OLD_Y, E_OLD_X: los rellena sys_render_init
   inc de
   inc de                   ;; E_COOLDOWN al azar: si no, todas las ovejas
   call rng_next            ;; darían el paso en el mismo frame
   and 7
   ld [de], a
   and a                    ;; carry a 0: creada
   ret

.array_full:
   ld b, b                  ;; breakpoint de BGB: hay más spawns que MAX_ENTITIES
.no_more:
   scf
   ret

ASSERT E_TYPE == 1 && E_Y == 2 && E_X == 3 && E_TILE == 4 && E_COOLDOWN == 7, "spawn_entity rellena los campos en este orden"

;;-----------------------------------------------------------------------------
;; scene_game_update: un frame de juego. Lo llama el gestor de escenas
;; justo después de wait_vblank.
scene_game_update::
   call sys_render_flush    ;; primero: es lo único que toca VRAM
   call joypad_read

   ld a, [game_won]
   or a
   jr nz, .won

   ld a, [paused]
   or a
   jr nz, .paused

   ld a, [joypad_pressed]
   bit PADB_START, a
   jp nz, pause_on

   call sys_input_update
   call sys_ai_update       ;; después del pastor: reaccionan en el mismo frame
   call sys_corral_update
   call sys_timer_update
   ret c                    ;; se acabó el tiempo: ya estamos en otra escena
   call hud_update
   jp sys_render_update     ;; último: encola lo que se haya movido

.paused:
   ld a, [joypad_pressed]
   bit PADB_START, a
   ret z
   jp pause_off

.won:
   call hud_update          ;; que se vea el último punto y el 00
   call sys_render_update
   ld hl, win_timer
   dec [hl]
   ret nz
   jp level_won

;;-----------------------------------------------------------------------------
;; sys_timer_update: descuenta un segundo cada FRAMES_PER_SECOND frames.
;; 📤 carry a 1 si el tiempo se acabó (y ya se ha cambiado de escena)
sys_timer_update:
   ld hl, frame_count
   dec [hl]
   jr nz, .no_change
   ld [hl], FRAMES_PER_SECOND
   ld a, [time_left + 1]    ;; BCD: restar y corregir con daa ($10 - 1 = $09)
   sub 1
   daa                      ;; $00 - 1 -> $99 con carry: hay que pedir prestado
   ld [time_left + 1], a
   ld a, [time_left]
   sbc 0                    ;; el carry baja al byte alto ($0100 - 1 = $0099)
   daa
   ld [time_left], a
   ld hl, hud_dirty
   set HUDB_TIME, [hl]
   ld a, [time_left]
   ld hl, time_left + 1
   or [hl]
   jr z, .time_up
.no_change:
   and a
   ret
.time_up:
   call record_check        ;; fin de partida: ¿récord nuevo?
   ld hl, text_time_up
   ld b, AFTER_MESSAGE_TITLE
   call scene_message_enter
   scf
   ret

;;-----------------------------------------------------------------------------
;; level_won: suma el bonus y pasa al mensaje de nivel superado o al final.
level_won:
   call score_add_time_bonus
   ld b, HIGH(POINTS_PER_LEVEL)
   ld c, LOW(POINTS_PER_LEVEL)
   call score_add

   ld hl, current_level
   inc [hl]
   ld a, [hl]
   cp NUM_LEVELS
   jr z, .game_completed
   ld hl, text_level_clear
   ld b, AFTER_MESSAGE_NEXT_LEVEL
   jp scene_message_enter
.game_completed:
   call record_check
   ld hl, text_game_completed
   ld b, AFTER_MESSAGE_TITLE
   jp scene_message_enter

;;-----------------------------------------------------------------------------
;; pause_on / pause_off: congela la partida y escribe/borra PAUSA.
;; Al quitarla, se repinta el fondo bajo el texto y todas las entidades
;; (alguna podía estar debajo).
pause_on:
   ld a, 1
   ld [paused], a
   ld hl, PAUSE_ADDRESS
   ld de, text_pause
   jp queue_text

pause_off:
   xor a
   ld [paused], a
   ld b, PAUSE_ROW
   ld c, PAUSE_TEXT_X
.restore:
   push bc
   call level_tile_at       ;; A = fondo de (B, C)
   push af
   call tilemap_address_of  ;; HL = su dirección en pantalla
   pop af
   call render_queue_push
   pop bc
   inc c
   ld a, c
   cp PAUSE_TEXT_X + 5
   jr nz, .restore
   jp sys_render_redraw_all

;;-----------------------------------------------------------------------------
;; Textos de esta escena y de los mensajes que lanza
text_pause:
   db "PAUSA", END_OF_LIST
text_level_clear::
   db "NIVEL SUPERADO", END_OF_LIST
text_time_up::
   db "TIEMPO AGOTADO", END_OF_LIST
text_game_completed::
   db "ENHORABUENA", END_OF_LIST
