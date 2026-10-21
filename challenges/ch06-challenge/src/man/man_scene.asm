;;==============================================================
;; Challenge 6 · Gestor de escenas (Scene Manager)
;; Sabe cuál es la escena actual, cambiar a otra y ejecutar su update.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Scene data", WRAM0
scene_current::  DS 2   ;; address of the current scene (its table)

SECTION "Scene manager", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A scene is a pair of routines in a table of 2 words:
;;      DW init, update
;; scene_change copies nothing: it only remembers WHICH scene is the current one.
;;
;; 📥 HL = address of the scene (the table), e.g. scene_game
;; Turns the screen off (safely), runs the scene's init, turns it on.
;; The init can draw whatever it wants: the screen is off.
;; ❌ Modifies A, BC, DE, HL
scene_change::
   INCBIN "bin/scene_change.bin"          ;; Rutina dada, en binario (26 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Runs the update of the current scene (once per frame).
scene_update::
   INCBIN "bin/scene_update.bin"          ;; Rutina dada, en binario (14 bytes)
