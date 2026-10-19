;;==============================================================
;; Challenge 5 · Gráficos: carga de tiles y fondo
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"

SECTION "Engine: graphics", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads tiles into VRAM and sets the palettes.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, DE, HL
gfx_init::
   INCBIN "bin/gfx_init.bin"              ;; Rutina dada, en binario (24 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draws the space background in the tilemap.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, DE, HL
bg_draw::
   INCBIN "bin/bg_draw.bin"               ;; Rutina dada, en binario (12 bytes)
