;;==============================================================
;; Challenge 6 · Sistema de animación (componente ANIMATION)
;; Elige qué imagen de su sheet muestra una entidad: depende de hacia
;; dónde mira y de su paso. Escribe el TILE y el ATTR: dibujarlos lo hace sys_prerender.
;;==============================================================
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "engine/hardware.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

ASSERT ANIM_STEP_MASK == TILES_PER_IMAGE   ;; the step bit is already the offset of the second image: no shift

SECTION "System: animation", ROM0

;; A sheet has 3 rows of images (down, up, side). The side row shows the entity
;; facing RIGHT: to face LEFT, the same images are mirrored (ATTR_XFLIP).
;; The index is the direction (DIR_DOWN, DIR_UP, DIR_LEFT, DIR_RIGHT): each entry is
;; 2 bytes, the first tile of its row (relative to the sheet), and the flip of its sprites.
DirImage::
   DB 0 * SHEET_ROW_TILES, 0            ;; DIR_DOWN:  row 0
   DB 1 * SHEET_ROW_TILES, 0            ;; DIR_UP:    row 1
   DB 2 * SHEET_ROW_TILES, ATTR_XFLIP   ;; DIR_LEFT:  row 2, mirrored
   DB 2 * SHEET_ROW_TILES, 0            ;; DIR_RIGHT: row 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 11: `sys_animation_one`
;; La implementas TÚ, en src/ej11.asm (etiqueta `ej11::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_animation_one` y no necesita saber dónde está tu código.
sys_animation_one::
   jp   go_ej11              ;; Salta al ejercicio 11 (ver main.asm)
   ds   20, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 12: `sys_animation_image`
;; La implementas TÚ, en src/ej12.asm (etiqueta `ej12::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_animation_image` y no necesita saber dónde está tu código.
sys_animation_image::
   jp   go_ej12              ;; Salta al ejercicio 12 (ver main.asm)
   ds   46, $00              ;; Relleno: las demás rutinas conservan su dirección
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Animation system, for ALL the entities that have ANIMATION.
;; ❌ Modifies A, BC, DE, HL
sys_animation_update::
   INCBIN "bin/sys_animation_update.bin"  ;; Rutina dada, en binario (8 bytes)
