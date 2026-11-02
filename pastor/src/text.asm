;;=============================================================================
;; text.asm — Escritura de textos y números en el tilemap
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Los textos son listas de tiles acabadas en el centinela END_OF_LIST
;; (charmap.inc traduce las letras a tiles al ensamblar).
;; Los números son un dígito por byte (ver score.asm).
;;
;; Dos variantes de cada rutina:
;;  - print_*: escribe en VRAM ya. Solo con la pantalla apagada.
;;  - queue_*: pasa por la cola de render; se puede usar en pleno juego.
;;=============================================================================
INCLUDE "constants.inc"

SECTION "Text CODE", ROM0

;;-----------------------------------------------------------------------------
;; print_text: copia un texto acabado en END_OF_LIST a VRAM.
;; ⚠️ Pantalla apagada.
;; 📥 HL = dirección en el tilemap, DE = texto
;; 📤 HL queda justo detrás del texto (para escribir algo a continuación)
;; Modifica: A, F, DE, HL
print_text::
   ld a, [de]
   cp END_OF_LIST
   ret z
   ld [hl+], a
   inc de
   jr print_text

;;-----------------------------------------------------------------------------
;; print_digits: escribe B dígitos (un byte cada uno) en VRAM.
;; ⚠️ Pantalla apagada.
;; 📥 HL = dirección en el tilemap, DE = primer dígito, B = cuántos
;; Modifica: A, F, B, DE, HL
print_digits::
   ld a, [de]
   add TILE_DIGIT_0
   ld [hl+], a
   inc de
   dec b
   jr nz, print_digits
   ret

;;-----------------------------------------------------------------------------
;; queue_text: encola un texto acabado en END_OF_LIST.
;; 📥 HL = dirección en el tilemap, DE = texto
;; Modifica: A, F, DE, HL
queue_text::
   ld a, [de]
   cp END_OF_LIST
   ret z
   push de
   push hl
   call render_queue_push   ;; pisa DE y HL: por eso los guardamos
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
;; queue_digits: como print_digits, pero por la cola.
;; 📥 HL = dirección en el tilemap, DE = primer dígito, B = cuántos
;; Modifica: A, F, B, DE, HL
queue_digits::
   ld a, [de]
   add TILE_DIGIT_0
   push de
   push hl
   call render_queue_push
   pop hl
   pop de
   inc hl
   inc de
   dec b
   jr nz, queue_digits
   ret
