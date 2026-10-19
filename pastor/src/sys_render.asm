;;=============================================================================
;; sys_render.asm — Sistema de dibujado de entidades en el tilemap
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; El VBLANK dura unos 1140 ciclos y recorrer las entidades cuesta casi eso,
;; así que el trabajo se parte en dos:
;;   1) sys_render_update (fuera del VBLANK, tras la lógica): decide qué hay
;;      que pintar y lo apunta en una cola de (dirección, tile).
;;   2) sys_render_flush (justo después de wait_vblank): solo copia la cola
;;      a la VRAM. Unos 14 ciclos por casilla.
;;
;; Cada entidad recuerda dónde está dibujada (E_OLD_Y, E_OLD_X). Si se ha
;; movido, se encola el fondo de la posición vieja y la entidad en la nueva.
;; Primero se encolan TODOS los borrados y luego TODOS los dibujos, para que
;; borrar la casilla que deja una entidad nunca tape a otra que acaba de llegar.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

;; Como mucho, cada entidad encola un borrado y un dibujo, más el marcador
DEF QUEUE_MAX   EQU MAX_ENTITIES * 2 + HUD_MAX_TILES
DEF QUEUE_ENTRY EQU 3        ;; dirección (2 bytes, little endian) + tile

SECTION "Render queue", WRAM0
render_queue_count: DS 1
render_queue:       DS QUEUE_MAX * QUEUE_ENTRY

SECTION "Render system CODE", ROM0

;;-----------------------------------------------------------------------------
;; sys_render_reset: vacía la cola. Llamar al empezar un nivel, antes de
;; que nadie encole nada.
;; Modifica: A
sys_render_reset::
   xor a
   ld [render_queue_count], a
   ret

;;-----------------------------------------------------------------------------
;; sys_render_init: dibuja todas las entidades (y lo que ya hubiera en la cola).
;; Para el inicio del nivel: LLAMAR CON LA PANTALLA APAGADA.
sys_render_init::
   ld hl, sys_render_queue_draw
   call man_entity_for_each
   jp sys_render_flush      ;; con la pantalla apagada se puede escribir ya

;;-----------------------------------------------------------------------------
;; sys_render_update: encola lo que haya cambiado este frame.
;; Llamar después de todos los sistemas que mueven entidades.
sys_render_update::
   ld hl, sys_render_queue_erase_moved
   call man_entity_for_each
   ld hl, sys_render_queue_draw_moved
   jp man_entity_for_each

;;-----------------------------------------------------------------------------
;; sys_render_flush: escribe la cola en VRAM y la vacía.
;; ⚠️ Llamar justo después de wait_vblank, antes que cualquier otra cosa.
;; Modifica: A, F, B, DE, HL
sys_render_flush::
   ld a, [render_queue_count]
   or a
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

;;-----------------------------------------------------------------------------
;; render_queue_push: añade (HL = dirección, A = tile) al final de la cola.
;; La cola no puede llenarse: QUEUE_MAX cubre el peor caso (todas las
;; entidades se mueven y el marcador cambia). Quien dibuje algo nuevo en
;; el VBLANK debe usar esta rutina y ampliar QUEUE_MAX si hace falta.
;; Modifica: A, F, DE, HL
render_queue_push::
   push af
   ld d, h
   ld e, l                  ;; DE = dirección a encolar
   ld a, [render_queue_count]
   ld l, a
   add a                    ;; A = count * 2
   add l                    ;; A = count * 3 (cabe en 8 bits: ver ASSERT)
   ld hl, render_queue
   add l
   ld l, a
   adc h
   sub l
   ld h, a                  ;; HL = render_queue + count * 3
   ld [hl], e
   inc hl
   ld [hl], d
   inc hl
   pop af
   ld [hl], a
   ld hl, render_queue_count
   inc [hl]
   ret

;;-----------------------------------------------------------------------------
;; sys_render_redraw_all: encola todas las entidades, se hayan movido o no.
;; Para cuando algo ha pintado encima de ellas (p. ej. el texto de PAUSA).
sys_render_redraw_all::
   ld hl, sys_render_queue_draw
   jp man_entity_for_each

;;-----------------------------------------------------------------------------
;; tilemap_address_of: versión pública de tilemap_address.
;; 📥 B = fila, C = columna  📤 HL = dirección en el tilemap
;; Modifica: A, F, HL
tilemap_address_of::
   ;; sigue en tilemap_address

;;-----------------------------------------------------------------------------
;; tilemap_address: dirección en el tilemap de la casilla (B, C).
;; Dirección = $9800 + fila * 32 + columna
;; 📥 B = fila, C = columna
;; 📤 HL = dirección
;; Modifica: A, F, HL
tilemap_address:
   ld h, 0
   ld l, b
   add hl, hl
   add hl, hl
   add hl, hl
   add hl, hl
   add hl, hl               ;; HL = fila * 32 (fila <= 17: cabe de sobra)
   ld a, l
   or c                     ;; fila * 32 tiene los 5 bits bajos a 0: OR = suma
   ld l, a
   ld a, h
   add HIGH(_SCRN0)         ;; $9800 tiene la parte baja a 0: basta sumar la alta
   ld h, a
   ret

;;-----------------------------------------------------------------------------
;; load_position: lee 2 campos seguidos (fila, columna) de la entidad.
;; 📥 DE = entidad, A = desplazamiento del primer campo (E_Y o E_OLD_Y)
;; 📤 B = fila, C = columna
;; Modifica: A, F, BC, HL
load_position:
   ld h, d
   add e                    ;; el array está alineado: E + campo no desborda
   ld l, a
   ld b, [hl]
   inc l
   ld c, [hl]
   ret

;;-----------------------------------------------------------------------------
;; has_moved: ¿la posición actual es distinta de la dibujada?
;; 📥 DE = entidad
;; 📤 Z a 1 si NO se ha movido
;; Modifica: A, F, BC, HL
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

;;-----------------------------------------------------------------------------
;; sys_render_queue_erase_moved: (para for_each) encola el fondo donde estaba.
;; 📥 DE = entidad
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

;;-----------------------------------------------------------------------------
;; sys_render_queue_draw_moved: (para for_each) encola la entidad en su sitio.
;; 📥 DE = entidad
sys_render_queue_draw_moved:
   call has_moved
   ret z
   ;; sigue en sys_render_queue_draw

;;-----------------------------------------------------------------------------
;; sys_render_queue_draw: (para for_each) encola la entidad y anota dónde.
;; 📥 DE = entidad
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

ASSERT QUEUE_MAX * QUEUE_ENTRY < 256, "la cola de render no cabe en 8 bits: render_queue_push dejaría de funcionar"
