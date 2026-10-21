;;==============================================================
;; Challenge 6 · Pantalla
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
   ld   hl, rLY
   ld   a, VBLANK_LINE
.wait
   cp   [hl]              ;; Comparing straight against [hl] keeps the loop short
   jr   nz, .wait
   ret

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
   ld   hl, rLCDC               ;; \ HL = the LCD control register
   bit  LCDC_ON_BIT, [hl]       ;; | Is the screen on?
   ret  z                       ;; / No: it is off already. Waiting would never end

   call wait_vblank             ;; Wait for VBLANK: now we are at line 144

   ld   hl, rLCDC               ;; \ HL = the LCD register again (wait_vblank changed HL)
   res  LCDC_ON_BIT, [hl]       ;; / Screen off: LCDC bit 7 = 0

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turns the screen on, with sprites and background enabled.
;; ❌ Modifies A
screen_on::
   ld   a, LCDC_VALUE
   ld   [rLCDC], a
   ret
