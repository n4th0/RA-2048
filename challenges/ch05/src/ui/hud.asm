;;==============================================================
;; Challenge 5 · HUD: el marcador
;; Puntos con 3 dígitos (000-999), un dígito en cada byte: sumar, dibujar y
;; redibujar en VBLANK.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "ui/hud.inc"

SECTION "Score data", WRAM0
score::          DS 3                 ;; the points: ONE DIGIT (0-9) IN EACH BYTE,
                                      ;; [score] = hundreds, [score + 1] = tens, [score + 2] = units
score_dirty::    DS 1                 ;; 1 → the HUD must be redrawn

SECTION "HUD", ROM0

txt_score:       DB "PUNTOS", TEXT_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the HUD: score = 000, and nothing to redraw.
;; ❌ Modifies A, B, HL
hud_init::
   INCBIN "bin/hud_init.bin"              ;; Rutina dada, en binario (14 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draws the HUD (the word PUNTOS and the score) at the top of the screen.
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A, DE, HL
hud_draw::
   INCBIN "bin/hud_draw.bin"              ;; Rutina dada, en binario (15 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Adds points to the score. It stops at 999.
;; The points are added to the units; every digit that reaches 10 goes back to
;; 0 (or gets 10 less) and adds 1 to the digit on its left: the "carry".
;; 📥 A = points (0-9)
;; ❌ Modifies A, B, HL
score_add::
   INCBIN "bin/score_add.bin"             ;; Rutina dada, en binario (42 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Writes the score (three digits) in the tilemap.
;; 📥 DE = address in the tilemap
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A, B, DE, HL
score_draw::
   INCBIN "bin/score_draw.bin"            ;; Rutina dada, en binario (14 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Redraws the score in the HUD if it has changed.
;; It is called right after the sprites are copied to the OAM, still in VBLANK.
;; ❌ Modifies A, B, DE, HL
hud_update::
   INCBIN "bin/hud_update.bin"            ;; Rutina dada, en binario (15 bytes)
