INCLUDE "hardware.inc"
INCLUDE "constants.inc"


DEF QUEUE_MAX   EQU MAX_ENTITIES * 2 + HUD_MAX_TILES
DEF QUEUE_ENTRY EQU 3        ;; dirección (2 bytes, little endian) + tile

SECTION "Render queue", WRAM0
render_queue_count: DS 1
render_queue:       DS QUEUE_MAX * QUEUE_ENTRY

SECTION "Render system CODE", ROM0


sys_render_reset::
   xor a
   ld [render_queue_count], a
   ret


sys_render_init::
   ld hl, sys_render_queue_draw
   call man_entity_for_each
   jp sys_render_flush      ;; con la pantalla apagada se puede escribir ya


sys_render_update::
   ld hl, sys_render_queue_erase_moved
   call man_entity_for_each
   ld hl, sys_render_queue_draw_moved
   jp man_entity_for_each


sys_render_flush::
   ld a, [render_queue_count]
   cp 0
   jr z, .done
   ld b, a
   ld hl, render_queue
.copy:
   ld a, [hl+]
   ld e, a
   ld a, [hl+]
   ld d, a                  ;; DE = dirección en el tilemap
   ld a, [hl+]
   ld [de], a               ;; tile
   dec b
   jr nz, .copy
   xor a
   ld [render_queue_count], a
.done:                      ;; los tests miden aquí si seguimos dentro del VBLANK
   ret


render_queue_push::
   push af
   ld d, h
   ld e, l                  ;; DE = dirección a encolar
   ld a, [render_queue_count]
   ld l, a
   add a                    ;; A = count * 2
   add l                    ;; A = count * 3 (como mucho 48 * 3 = 144: cabe en 8 bits)
   ld hl, render_queue      ;; HL = render_queue + count * 3 (16 bits: add + adc)
   add l
   ld l, a
   ld a, h
   adc 0
   ld h, a
   ld [hl], e
   inc hl
   ld [hl], d
   inc hl
   pop af
   ld [hl], a
   ld hl, render_queue_count
   inc [hl]
   ret


sys_render_redraw_all::
   ld hl, sys_render_queue_draw
   jp man_entity_for_each


tilemap_address::
   ld h, 0
   ld l, b
   add hl, hl               ;; *2
   add hl, hl               ;; *4
   add hl, hl               ;; *8
   add hl, hl               ;; *16
   add hl, hl               ;; HL = fila * 32
   ld a, l                  ;; HL += columna + $9800 (16 bits: add + adc)
   add c
   ld l, a
   ld a, h
   adc HIGH(_SCRN0)         ;; LOW(_SCRN0) es 0: en la parte baja no hay nada que sumar
   ld h, a
   ret


load_position:
   ld h, d
   add e                    ;; el array está alineado: E + campo no desborda
   ld l, a
   ld b, [hl]
   inc l
   ld c, [hl]
   ret


has_moved:
   ld a, E_Y
   call load_position       ;; B, C = posición actual
   ld a, E_OLD_Y
   add e
   ld l, a                  ;; HL = &E_OLD_Y (H sigue siendo D)
   ld a, [hl+]
   cp b
   ret nz
   ld a, [hl]
   cp c
   ret


sys_render_queue_erase_moved:
   call has_moved
   ret z
   ld a, E_OLD_Y
   call load_position       ;; B, C = posición vieja
   call level_tile_at       ;; A = tile de fondo de esa casilla
   push af
   call tilemap_address
   pop af
   jp render_queue_push


sys_render_queue_draw_moved:
   call has_moved
   ret z
   jr sys_render_queue_draw


sys_render_queue_draw:
   ld a, E_Y
   call load_position       ;; B, C = posición actual
   ld a, E_OLD_Y            ;; E_OLD = posición actual: ya queda encolada
   add e
   ld l, a
   ld [hl], b
   inc l
   ld [hl], c

   ld a, E_TILE
   add e
   ld l, a
   ld a, [hl]               ;; A = tile de la entidad
   push af
   call tilemap_address
   pop af
   jp render_queue_push

