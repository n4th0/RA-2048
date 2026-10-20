;;=============================================================================
;; scene_game.asm — Escena de juego: niveles, sistemas, tiempo y pausa
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"

;; "PAUSA" (5 letras) centrado en la fila 9: columna (20 - 5) / 2 = 7
DEF PAUSE_ROW     EQU 9
DEF PAUSE_COL     EQU 7
DEF PAUSE_LENGTH  EQU 5

SECTION "Scene game state", WRAM0
current_level:: DS 1           ;; 0 .. NUM_LEVELS - 1
time_left::     DS TIME_DIGITS ;; segundos que quedan, un dígito por byte
frame_count:    DS 1           ;; frames hasta el siguiente segundo
paused::        DS 1
win_timer:      DS 1           ;; frames de espera tras ganar, antes del mensaje

SECTION "Scene game CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_game_new_game: empieza una partida desde el nivel 1.
scene_game_new_game::
   call score_reset
   xor a
   ld [current_level], a
   jr scene_game_enter_level

;;-----------------------------------------------------------------------------
;; scene_game_enter_level: carga current_level y pasa a la escena de juego.
scene_game_enter_level::
   call lcd_off

   ;;--- HL = level_table + current_level * LEVEL_ENTRY_SIZE ---
   ;; (sumando LEVEL_ENTRY_SIZE tantas veces como indique el nivel)
   ld hl, level_table
   ld de, LEVEL_ENTRY_SIZE
   ld a, [current_level]
.find_entry:
   cp 0
   jr z, .entry_found
   add hl, de
   dec a
   jr .find_entry
.entry_found:

   ;;--- Leer la entrada: mapa (2 bytes), spawns (2 bytes), tiempo (3 dígitos) ---
   ld a, [hl+]
   ld c, a
   ld a, [hl+]
   ld b, a                  ;; BC = mapa
   ld a, [hl+]
   ld e, a
   ld a, [hl+]
   ld d, a                  ;; DE = spawns
   push bc
   push de
   ld de, time_left         ;; copiar los 3 dígitos del tiempo
   ld bc, TIME_DIGITS
   call memcpy
   pop de
   pop hl                   ;; HL = mapa, DE = spawns

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
;; 📥 HL = puntero a la lista (fila, columna, ..., END_OF_LIST)
;;    A = tipo, C = tile
;; 📤 HL avanzado al siguiente par
;;    carry a 1 si la lista se acabó o el array está lleno (no se creó nada)
;; Modifica: A, F, BC, DE, HL
spawn_entity:
   ld b, a                  ;; B = tipo
   ld a, [hl]
   cp END_OF_LIST           ;; centinela: no hay más entidades
   jr z, .no_more

   push bc
   push hl
   call man_entity_alloc    ;; DE = entidad nueva
   pop hl
   pop bc
   jr c, .no_more           ;; array lleno (no debería pasar: MAX_ENTITIES = 16)

   inc de                   ;; E_TYPE (campo 1)
   ld a, b
   ld [de], a
   inc de                   ;; E_Y (campo 2)
   ld a, [hl+]
   ld [de], a
   inc de                   ;; E_X (campo 3)
   ld a, [hl+]
   ld [de], a
   inc de                   ;; E_TILE (campo 4)
   ld a, c
   ld [de], a
   ld a, b                  ;; el pastor empieza con cooldown 0 (alloc ya lo puso a 0)
   cp TYPE_SHEPHERD
   jr z, .created
   inc de                   ;; E_OLD_Y, E_OLD_X (campos 5 y 6): los rellena sys_render_init
   inc de
   inc de                   ;; E_COOLDOWN (campo 7) de las ovejas al azar: si no,
   call rng_next            ;; todas darían el paso en el mismo frame
   and %00000111            ;; 0..7
   ld [de], a
.created:
   xor a                    ;; carry a 0: creada
   ret

.no_more:
   scf
   ret

;;-----------------------------------------------------------------------------
;; scene_game_update: un frame de juego. Lo llama el gestor de escenas
;; justo después de wait_vblank.
scene_game_update::
   call sys_render_flush    ;; primero: es lo único que toca VRAM
   call joypad_read

   ld a, [game_won]
   cp 0
   jr nz, .won

   ld a, [paused]
   cp 0
   jr nz, .paused

   ld a, [joypad_pressed]
   bit BTN_START, a
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
   bit BTN_START, a
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

   ;;--- Restar 1 segundo, empezando por las unidades ---
   ;; Si un dígito vale 0, pasa a 9 y "pedimos prestado" al de su izquierda.
   ld hl, time_left + TIME_DIGITS - 1   ;; unidades
.borrow:
   ld a, [hl]
   cp 0
   jr nz, .subtract
   ld [hl], 9
   dec hl
   jr .borrow
.subtract:
   dec [hl]
   ld a, 1
   ld [hud_dirty], a

   ;;--- ¿Ha llegado a 000? (los 3 dígitos suman 0 solo si todos son 0) ---
   ld hl, time_left
   ld a, [hl+]
   add [hl]
   inc hl
   add [hl]
   cp 0
   jr z, .time_up
.no_change:
   xor a                    ;; carry a 0: seguimos jugando
   ret
.time_up:
   call record_check        ;; fin de partida: ¿récord nuevo?
   ld hl, _SCRN0 + 5 * MAP_STRIDE + 3      ;; "TIEMPO AGOTADO" (14): columna 3
   ld de, text_time_up
   ld b, AFTER_MESSAGE_TITLE
   call scene_message_enter
   scf
   ret


;;-----------------------------------------------------------------------------
;; level_won: suma el bonus y pasa al mensaje de nivel superado o al final.
;; Bonus = 100 puntos + 10 por cada segundo que sobre. Multiplicar el tiempo
;; por 10 es correr sus dígitos una posición a la izquierda:
;;   unidades de segundo -> decenas de puntos, decenas -> centenas, ...
level_won:
   ld a, [time_left + 2]    ;; unidades de segundo -> decenas de puntos
   ld hl, score + 4
   call score_add_digit
   ld a, [time_left + 1]    ;; decenas de segundo -> centenas de puntos
   ld hl, score + 3
   call score_add_digit
   ld a, [time_left + 0]    ;; centenas de segundo -> millares de puntos
   ld hl, score + 2
   call score_add_digit
   ld a, 1                  ;; + 100 puntos por superar el nivel
   ld hl, score + 3
   call score_add_digit

   ld hl, current_level
   inc [hl]
   ld a, [hl]
   cp NUM_LEVELS
   jr z, .game_completed
   ld hl, _SCRN0 + 5 * MAP_STRIDE + 3      ;; "NIVEL SUPERADO" (14): columna 3
   ld de, text_level_clear
   ld b, AFTER_MESSAGE_NEXT_LEVEL
   jp scene_message_enter
.game_completed:
   call record_check
   ld hl, _SCRN0 + 5 * MAP_STRIDE + 4      ;; "ENHORABUENA" (11): columna 4
   ld de, text_game_completed
   ld b, AFTER_MESSAGE_TITLE
   jp scene_message_enter

;;-----------------------------------------------------------------------------
;; pause_on / pause_off: congela la partida y escribe/borra PAUSA.
;; Al quitarla, se repinta el fondo bajo el texto y todas las entidades
;; (alguna podía estar debajo).
pause_on:
   ld a, 1
   ld [paused], a
   ld hl, _SCRN0 + PAUSE_ROW * MAP_STRIDE + PAUSE_COL
   ld de, text_pause
   jp queue_text

pause_off:
   xor a
   ld [paused], a
   ld b, PAUSE_ROW
   ld c, PAUSE_COL
.restore:
   push bc
   call level_tile_at       ;; A = fondo de (B, C)
   push af
   call tilemap_address     ;; HL = su dirección en pantalla
   pop af
   call render_queue_push
   pop bc
   inc c
   ld a, c
   cp PAUSE_COL + PAUSE_LENGTH
   jr nz, .restore
   jp sys_render_redraw_all

;;-----------------------------------------------------------------------------
;; Textos de esta escena y de los mensajes que lanza
text_pause:
   db "PAUSA", END_OF_LIST
text_level_clear:
   db "NIVEL SUPERADO", END_OF_LIST
text_time_up:
   db "TIEMPO AGOTADO", END_OF_LIST
text_game_completed:
   db "ENHORABUENA", END_OF_LIST
