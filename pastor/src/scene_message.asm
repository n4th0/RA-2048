INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"

DEF MIN_SHOW_FRAMES EQU 30   
                             

SECTION "Scene message state", WRAM0
after_message: DS 1          
show_timer:    DS 1

SECTION "Scene message CODE", ROM0


scene_message_enter::
   ld a, b
   ld [after_message], a
   push de
   push hl
   call lcd_off
   call sys_render_reset
   ld hl, screen_frame
   call level_load
   pop hl
   pop de
   call print_text         

   ld hl, _SCRN0 + 9 * MAP_STRIDE + 3     
   ld de, text_points
   call print_text
   ld de, score
   ld b, SCORE_DIGITS
   call print_digits

   ld hl, _SCRN0 + 11 * MAP_STRIDE + 3    
   ld de, text_record
   call print_text
   ld de, record
   ld b, SCORE_DIGITS
   call print_digits

   ld a, [after_message]    
   cp AFTER_MESSAGE_TITLE
   jr nz, .no_record
   ld a, [new_record]
   cp 0
   jr z, .no_record
   ld hl, _SCRN0 + 13 * MAP_STRIDE + 4   
   ld de, text_new_record
   call print_text
.no_record:
   ld hl, _SCRN0 + 15 * MAP_STRIDE + 4    
   ld de, text_press_start_msg
   call print_text

   ld a, MIN_SHOW_FRAMES
   ld [show_timer], a
   call lcd_on
   ld a, SCENE_MESSAGE
   ld [scene_id], a
   ret

;; scene_message_update: espera a START y sigue.
scene_message_update::
   call music_update
   call sys_render_flush
   call joypad_read
   ld hl, show_timer
   ld a, [hl]
   cp 0
   jr z, .accept
   dec [hl]
   ret
.accept:
   ld a, [joypad_pressed]
   bit BTN_START, a
   ret z
   call music_stop
   ld a, [after_message]
   cp AFTER_MESSAGE_NEXT_LEVEL
   jp z, scene_game_enter_level
   jp scene_title_enter

text_points:
   db "PUNTOS ", END_OF_LIST
text_new_record:
   db "NUEVO RECORD", END_OF_LIST
text_press_start_msg:
   db "PULSA START", END_OF_LIST
