;;=============================================================================
;; scene_message.asm — Pantalla de mensaje entre niveles y al acabar
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Muestra un título (NIVEL SUPERADO, TIEMPO AGOTADO, ENHORABUENA), los
;; puntos y el récord. START continúa según after_message.
;;=============================================================================
INCLUDE "text.inc"

DEF TITLE_ROW       EQU 5
DEF SCORE_ROW       EQU 9
DEF RECORD_ROW      EQU 11
DEF NEW_RECORD_ROW  EQU 13
DEF MIN_SHOW_FRAMES EQU 30   ;; ignora START al principio: si no, un toque
                             ;; tardío del juego se saltaría el mensaje

SECTION "Scene message state", WRAM0
after_message: DS 1          ;; AFTER_MESSAGE_*
show_timer:    DS 1

SECTION "Scene message CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_message_enter: dibuja el mensaje y pasa a esta escena.
;; 📥 HL = título (acabado en END_OF_LIST, como mucho 18 letras para no tapar la valla)
;;    B = qué hacer con START (AFTER_MESSAGE_NEXT_LEVEL / _TITLE)
scene_message_enter::
   ld a, b
   ld [after_message], a
   push hl
   call lcd_off
   call sys_render_reset
   ld hl, screen_frame
   call level_load
   pop de                   ;; DE = título

   ;; Centrado en tiempo de ejecución: el texto llega en un registro
   ld h, d
   ld l, e
   ld c, 0
.measure:
   ld a, [hl+]
   cp END_OF_LIST
   jr z, .measured
   inc c
   jr .measure
.measured:
   ld a, SCREEN_W
   sub c
   srl a                    ;; columna = (20 - longitud) / 2
   ld hl, _SCRN0 + TITLE_ROW * MAP_STRIDE
   add l
   ld l, a                  ;; fila * 32 + col < 256 por encima de la base: sin acarreo
   call print_text

   ld hl, _SCRN0 + SCORE_ROW * MAP_STRIDE + 3
   ld de, text_points
   call print_text
   ld de, score
   ld b, SCORE_BYTES
   call print_bcd

   ld hl, _SCRN0 + RECORD_ROW * MAP_STRIDE + 3
   ld de, text_record
   call print_text
   ld de, record
   ld b, SCORE_BYTES
   call print_bcd

   ld a, [after_message]    ;; "NUEVO RECORD" solo al acabar la partida
   cp AFTER_MESSAGE_TITLE
   jr nz, .no_record
   ld a, [new_record]
   or a
   jr z, .no_record
   TEXT_CENTERED NEW_RECORD_ROW, "NUEVO RECORD"
.no_record:
   TEXT_CENTERED 15, "PULSA START"

   ld a, MIN_SHOW_FRAMES
   ld [show_timer], a
   call lcd_on
   ld a, SCENE_MESSAGE
   ld [scene_id], a
   ret

ASSERT LOW(_SCRN0 + TITLE_ROW * MAP_STRIDE) + SCREEN_W < 256, "el centrado del título necesitaría acarreo"

;;-----------------------------------------------------------------------------
;; scene_message_update: espera a START y sigue.
scene_message_update::
   call sys_render_flush
   call joypad_read
   ld hl, show_timer
   ld a, [hl]
   or a
   jr z, .accept
   dec [hl]
   ret
.accept:
   ld a, [joypad_pressed]
   bit PADB_START, a
   ret z
   ld a, [after_message]
   cp AFTER_MESSAGE_NEXT_LEVEL
   jp z, scene_game_enter_level
   jp scene_title_enter

text_points:
   db "PUNTOS ", END_OF_LIST
