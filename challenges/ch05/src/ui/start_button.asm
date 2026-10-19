;;==============================================================
;; Challenge 5 · Botón Start
;; Dibujado con sprites y con un efecto de paleta.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "ui/start_button.inc"

SECTION "Start button", ROM0

;; The Start button of the Game Boy, drawn with 8 sprites: a pill (3 sprites)
;; and the word START below (5 sprites, with the same font as the texts).
;; They are written in the OAM slots 0-7, which the entities never touch
;; (see START_BUTTON_OAM), and they stay there until they are hidden.
;; The sprites use the palette 1: fx_update changes it, so the button pulses.
;; Each sprite: Y, X, TILE, ATTR (bit 4 = palette 1)
StartButtonSprites:
   DB 104, 76, TILE_START_L, $10
   DB 104, 84, TILE_START_M, $10
   DB 104, 92, TILE_START_R, $10
   DB 116, 68, "S" - ASCII_TILE_OFFSET, $10     ;; ASCII → tile, as in text_draw
   DB 116, 76, "T" - ASCII_TILE_OFFSET, $10
   DB 116, 84, "A" - ASCII_TILE_OFFSET, $10
   DB 116, 92, "R" - ASCII_TILE_OFFSET, $10
   DB 116, 100, "T" - ASCII_TILE_OFFSET, $10

;; The 8 steps of the pulse (each lasts 8 frames): palette 1 of the sprites.
;; Colour 3 (the white of the button) goes white → grey → black → grey...
StartPulsePalettes:
   DB %00011011, %00011011, %01101111, %10111111
   DB %11111111, %11111111, %10111111, %01101111

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shows the Start button.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, B, DE, HL
start_button_show::
   INCBIN "bin/start_button_show.bin"     ;; Rutina dada, en binario (11 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Palette effect: changes the palette 1 every 8 frames, so the Start
;; button pulses. A palette is just a register: nothing is redrawn.
;; It is called in VBLANK, so the colour changes between frames, not in the middle of one.
;; ❌ Modifies A, DE, HL
fx_update::
   INCBIN "bin/fx_update.bin"             ;; Rutina dada, en binario (20 bytes)
