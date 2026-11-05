INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"


DEF PAUSE_ROW     EQU 9
DEF PAUSE_COL     EQU 7
DEF PAUSE_LENGTH  EQU 5

SECTION "Scene game state", WRAM0
current_level:: DS 1           
time_left::     DS TIME_DIGITS 
frame_count:    DS 1           
paused::        DS 1
win_timer:      DS 1           
win_anim_timer: DS 1
win_anim_state: DS 1
sheep_pose_tile: DS 1

SECTION "Scene game CODE", ROM0


scene_game_new_game::
   call score_reset
   xor a
   ld [current_level], a
   jr scene_game_enter_level


scene_game_enter_level::
   call lcd_off


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
   ld a, 10
   ld [win_anim_timer], a
   ld a, 1
   ld [win_anim_state], a

   call hud_init
   call sys_render_flush    ;; marcador a VRAM ya (pantalla apagada)
   call lcd_on
   ld a, SCENE_GAME
   ld [scene_id], a
   ret


scene_game_init::
   push de
   call sys_render_reset
   call level_load
   call man_entity_init
   call rng_init            ;; antes de los spawns: reparte sus cooldowns
   pop hl                   ;; HL = spawns

   ;; Primero el pastor, después ovejas y, opcionalmente, lobos
   ld a, TYPE_SHEPHERD
   ld c, TILE_SHEPHERD
   call spawn_entity
   ret c                    ;; lista vacía o array lleno: nada más que crear
.sheep:
   ld a, [hl]
   cp END_OF_SHEEP
   jr z, .wolf
   ld a, TYPE_SHEEP
   ld c, TILE_SHEEP
   call spawn_entity
   jr nc, .sheep

   jr .entities_done
.wolf:
   inc hl
.wolves:
   ld a, TYPE_WOLF
   ld c, TILE_WOLF
   call spawn_entity
   jr nc, .wolves
.entities_done:
   call sys_corral_init     
   jp sys_render_init       


spawn_entity:
   ld b, a                  
   ld a, [hl]
   cp END_OF_LIST           
   jr z, .no_more

   push bc
   push hl
   call man_entity_alloc    
   pop hl
   pop bc
   jr c, .no_more           

   inc de                   
   ld a, b
   ld [de], a
   inc de                   
   ld a, [hl+]
   ld [de], a
   inc de                   
   ld a, [hl+]
   ld [de], a
   inc de                   
   ld a, c
   ld [de], a
   ld a, b                  
   cp TYPE_SHEPHERD
   jr z, .created
   inc de                   
   inc de
   inc de                   
   call rng_next            
   and %00000111            
   ld [de], a
.created:
   xor a                   
   ret

.no_more:
   scf
   ret


scene_game_update::
   call sys_render_flush    
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
   call sys_ai_update       
   call sys_corral_update
   call sys_timer_update
   ret c                    
   call hud_update
   jp sys_render_update     

.paused:
   ld a, [joypad_pressed]
   bit BTN_START, a
   ret z
   jp pause_off

.won:
   call hud_update          
   ld hl, win_anim_timer
   dec [hl]
   jr nz, .win_anim_done
   ld [hl], 10
   ld a, [win_anim_state]
   xor 1
   ld [win_anim_state], a
   call scene_game_set_sheep_pose
.win_anim_done:
   call sys_render_update
   ld hl, win_timer
   dec [hl]
   ret nz
   jp level_won


scene_game_set_sheep_pose:
   ld a, [win_anim_state]
   and a
   jr z, .normal
   ld a, TILE_SHEEP_HAPPY
   jr .set
.normal:
   ld a, TILE_SHEEP
.set:
   ld [sheep_pose_tile], a
   ld hl, scene_game_set_sheep_pose_one
   jp man_entity_for_each

scene_game_set_sheep_pose_one:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl]
   cp TYPE_SHEEP_PENNED
   ret nz
   ld a, E_TILE
   add e
   ld l, a
   ld a, [sheep_pose_tile]
   ld [hl], a
   jp sys_render_queue_draw


sys_timer_update:
   ld hl, frame_count
   dec [hl]
   jr nz, .no_change
   ld [hl], FRAMES_PER_SECOND


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



level_won:
   call music_level_clear_start
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


text_pause:
   db "PAUSA", END_OF_LIST
text_level_clear:
   db "NIVEL SUPERADO", END_OF_LIST
text_time_up:
   db "TIEMPO AGOTADO", END_OF_LIST
text_game_completed:
   db "ENHORABUENA", END_OF_LIST
