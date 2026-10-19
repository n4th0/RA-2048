;;==============================================================
;; Challenge 5 · Pantalla
;; wait_vblank, screen_off y screen_on
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Engine: screen", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Waits until the screen starts drawing line 144: the beginning of VBLANK.
;; ❌ Modifies A, HL
;; ⚠️ If the screen is OFF, LY never changes and this NEVER returns.
wait_vblank::
   INCBIN "bin/wait_vblank.bin"           ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turns the screen off, the safe way.
;;
;; ⚠️ The screen must ONLY be turned off during VBLANK. Turning it off
;;    in the middle of a frame can damage a real Game Boy screen.
;;    That's why this routine waits for VBLANK itself, and does NOT trust
;;    the caller to be there already. Never turn the screen off any
;;    other way.
;; ❌ Modifies A, HL
screen_off::
   INCBIN "bin/screen_off.bin"            ;; Rutina dada, en binario (15 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turns the screen on, with sprites and background enabled.
;; ❌ Modifies A
screen_on::
   INCBIN "bin/screen_on.bin"             ;; Rutina dada, en binario (6 bytes)
