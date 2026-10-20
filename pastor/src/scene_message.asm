;;=============================================================================
;; scene_message.asm — Pantalla de mensaje entre niveles y al acabar
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Muestra un título (NIVEL SUPERADO, TIEMPO AGOTADO, ENHORABUENA), los
;; puntos y el récord. START continúa según after_message.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"

DEF MIN_SHOW_FRAMES EQU 30   ;; ignora START al principio: si no, un toque
                             ;; tardío del juego se saltaría el mensaje

SECTION "Scene message state", WRAM0
after_message: DS 1          ;; AFTER_MESSAGE_*
show_timer:    DS 1

SECTION "Scene message CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_message_enter: dibuja el mensaje y pasa a esta escena.
;; 📥 HL = dónde escribir el título en el tilemap (ya centrado por quien llama)
;;    DE = título (acabado en END_OF_LIST)
;;    B  = qué hacer con START (AFTER_MESSAGE_NEXT_LEVEL / _TITLE)
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
   call print_text          ;; el título

   ld hl, _SCRN0 + 9 * MAP_STRIDE + 3     ;; "PUNTOS " y 6 dígitos (13): columna 3
   ld de, text_points
   call print_text
   ld de, score
   ld b, SCORE_DIGITS
   call print_digits

   ld hl, _SCRN0 + 11 * MAP_STRIDE + 3    ;; "RECORD " y 6 dígitos
   ld de, text_record
   call print_text
   ld de, record
   ld b, SCORE_DIGITS
   call print_digits

   ld a, [after_message]    ;; "NUEVO RECORD" solo al acabar la partida
   cp AFTER_MESSAGE_TITLE
   jr nz, .no_record
   ld a, [new_record]
   cp 0
   jr z, .no_record
   ld hl, _SCRN0 + 13 * MAP_STRIDE + 4    ;; "NUEVO RECORD" (12): columna 4
   ld de, text_new_record
   call print_text
.no_record:
   ld hl, _SCRN0 + 15 * MAP_STRIDE + 4    ;; "PULSA START" (11): columna 4
   ld de, text_press_start_msg
   call print_text

   ld a, MIN_SHOW_FRAMES
   ld [show_timer], a
   call lcd_on
   ld a, SCENE_MESSAGE
   ld [scene_id], a
   ret

;;-----------------------------------------------------------------------------
;; scene_message_update: espera a START y sigue.
scene_message_update::
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
