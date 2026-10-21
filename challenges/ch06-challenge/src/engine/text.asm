;;==============================================================
;; Challenge 6 · Texto en ASCII
;; text_draw
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "assets/gfx/gfx.inc"

SECTION "Engine: text", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Writes a text in the tilemap.
;; The text is plain ASCII, finished with TEXT_END (a 0, like in C):
;;      DB "GAME OVER", TEXT_END
;; The font in the tiles follows ASCII (space, punctuation, digits and capitals:
;; $20-$5F), so each character becomes its tile with a subtraction:
;;      tile = ASCII code - ASCII_TILE_OFFSET
;; Lower case letters have no tiles: use capitals.
;; (RGBDS can also convert the text while assembling, with CHARMAP.
;;  Here the program does it, so you can see ASCII at work.)
;; 📥 HL = text, DE = address in the tilemap
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A, DE, HL
text_draw::
   INCBIN "bin/text_draw.bin"             ;; Rutina dada, en binario (10 bytes)
