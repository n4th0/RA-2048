;;==============================================================
;; Challenge 6 · Sistema de render: de la Shadow OAM a la OAM, y el scroll
;; Es lo único de dibujo que comparten TODAS las escenas, y además marca el
;; ritmo del juego (espera a VBLANK). Todo lo que cambia la pantalla y no puede
;; esperar se hace aquí, en VBLANK: los sprites (por DMA) y el scroll del background.
;; La Shadow OAM está en engine/oam.asm. Preparar los sprites (pre-render) es cosa
;; de la escena que tiene entidades: está en sys/sys_prerender.asm.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "sys/sys_render.inc"

SECTION "System: render", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 03: `sys_render_scroll`
;; La implementas TÚ, en src/ej03.asm (etiqueta `ej03::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_render_scroll` y no necesita saber dónde está tu código.
sys_render_scroll::
   jp   go_ej03              ;; Salta al ejercicio 03 (ver main.asm)
   ds   7, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shows the frame: waits for VBLANK, copies the shadow OAM to the OAM (by DMA)
;; and scrolls the background. The OAM can only be written during VBLANK (and with the screen off).
;; This routine knows nothing about entities: it is a plain copy.
;; ❌ May modify A, BC
sys_render_update::
   INCBIN "bin/sys_render_update.bin"     ;; Rutina dada, en binario (9 bytes)
