;;==============================================================
;; Challenge 5 · Joypad
;; input_update
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Joypad data", WRAM0
input_held::     DS 1  ;; buttons pressed now
input_pressed::  DS 1  ;; buttons that have just been pressed

SECTION "Engine: joypad", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the joypad: no buttons pressed.
;; ❌ Modifies A
input_init::
   INCBIN "bin/input_init.bin"            ;; Rutina dada, en binario (8 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reads the joypad once per frame.
;; ⫷▬ input_held:    buttons pressed now      (1 = pressed, bits BTN_*_BIT)
;;    input_pressed: buttons pressed since the last frame (the "edge")
;; ❌ Modifies A, B, HL
input_update::
   INCBIN "bin/input_update.bin"          ;; Rutina dada, en binario (34 bytes)
