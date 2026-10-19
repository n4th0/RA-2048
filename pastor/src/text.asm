;;=============================================================================
;; text.asm — Escritura de textos y números BCD en el tilemap
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Dos variantes de cada rutina:
;;  - directa (print_*): escribe en VRAM ya. Solo con la pantalla apagada.
;;  - en cola (queue_*): pasa por la cola de render, se puede usar en juego.
;;=============================================================================
INCLUDE "text.inc"

SECTION "Text CODE", ROM0

;;-----------------------------------------------------------------------------
;; print_text: copia un texto acabado en END_OF_LIST a VRAM.
;; ⚠️ Pantalla apagada.
;; 📥 HL = dirección en el tilemap, DE = texto
;; Modifica: A, F, DE, HL
print_text::
   ld a, [de]
   cp END_OF_LIST
   ret z
   ld [hl+], a
   inc de
   jr print_text

;;-----------------------------------------------------------------------------
;; print_bcd: escribe B bytes BCD (2 dígitos cada uno, el más significativo
;; primero) en VRAM.
;; ⚠️ Pantalla apagada.
;; 📥 HL = dirección en el tilemap, DE = primer byte, B = número de bytes
;; Modifica: A, F, B, C, DE, HL
print_bcd::
   ld a, [de]
   ld c, a
   swap a                   ;; decenas: el nibble alto
   and $0F
   add TILE_DIGIT_0
   ld [hl+], a
   ld a, c                  ;; unidades: el nibble bajo
   and $0F
   add TILE_DIGIT_0
   ld [hl+], a
   inc de
   dec b
   jr nz, print_bcd
   ret

;;-----------------------------------------------------------------------------
;; queue_text: encola un texto acabado en END_OF_LIST.
;; Para mostrar o cambiar texto con la pantalla encendida.
;; 📥 HL = dirección en el tilemap, DE = texto
;; Modifica: A, F, BC, DE, HL
queue_text::
   ld a, [de]
   cp END_OF_LIST
   ret z
   push de
   push hl
   call render_queue_push
   pop hl
   pop de
   inc hl
   inc de
   jr queue_text

;;-----------------------------------------------------------------------------
;; queue_blank: encola B tiles en blanco seguidos (para borrar un texto).
;; 📥 HL = dirección en el tilemap, B = cuántos
;; Modifica: A, F, B, DE, HL
queue_blank::
   push hl
   ld a, TILE_BLANK
   call render_queue_push
   pop hl
   inc hl
   dec b
   jr nz, queue_blank
   ret

;;-----------------------------------------------------------------------------
;; queue_bcd: como print_bcd pero por la cola.
;; 📥 HL = dirección en el tilemap, DE = primer byte, B = número de bytes
;; Modifica: A, F, BC, DE, HL
queue_bcd::
   ld a, [de]
   ld c, a
   swap a
   and $0F
   add TILE_DIGIT_0
   call .push_digit
   ld a, c
   and $0F
   add TILE_DIGIT_0
   call .push_digit
   inc de
   dec b
   jr nz, queue_bcd
   ret
.push_digit:                ;; render_queue_push pisa DE y HL: los guardamos
   push bc
   push de
   push hl
   call render_queue_push
   pop hl
   pop de
   pop bc
   inc hl
   ret
