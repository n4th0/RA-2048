INCLUDE "constants.inc"

SECTION "Text CODE", ROM0


print_text::
   ld a, [de]
   cp END_OF_LIST
   ret z
   ld [hl+], a
   inc de
   jr print_text


print_digits::
   ld a, [de]
   add TILE_DIGIT_0
   ld [hl+], a
   inc de
   dec b
   jr nz, print_digits
   ret



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



queue_blank::
   push hl
   ld a, TILE_BLANK
   call render_queue_push
   pop hl
   inc hl
   dec b
   jr nz, queue_blank
   ret



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
