;;==============================================================
;; Challenge 5 · Sistema de render: de la OAM sombra a la OAM
;; Es lo único de dibujo que comparten TODAS las escenas, y además marca el
;; ritmo del juego (espera a VBLANK). La OAM sombra está en engine/oam.asm. Preparar los sprites (pre-render) es cosa
;; de la escena que tiene entidades: está en sys/sys_prerender.asm.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "sys/sys_render.inc"

SECTION "System: render", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 08: `sys_render_update`
;; La implementas TÚ, en src/ej08.asm (etiqueta `ej08::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_render_update` y no necesita saber dónde está tu código.
sys_render_update::
   jp   go_ej08              ;; Salta al ejercicio 08 (ver main.asm)
   ds   11, $00              ;; Relleno: las demás rutinas conservan su dirección
