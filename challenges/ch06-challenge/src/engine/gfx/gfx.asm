;;==============================================================
;; Challenge 6 · Gráficos: carga de tiles y background
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"

SECTION "Engine: graphics", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads tiles into VRAM and sets the palettes.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, DE, HL
gfx_init::
   INCBIN "bin/gfx_init.bin"              ;; Rutina dada, en binario (26 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Empties the background: every cell of the tilemap is the blank tile.
;; The scenes that are only text (menu, game over...) start from here.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, HL
bg_clear::
   INCBIN "bin/bg_clear.bin"              ;; Rutina dada, en binario (15 bytes)
