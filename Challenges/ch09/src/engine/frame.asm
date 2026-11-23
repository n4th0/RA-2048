;;==============================================================
;; Challenge 5 · Contador de fotogramas
;; Lo usan el generador de números aleatorios (para la semilla) y el efecto
;; de paleta del botón Start. Solo se escribe aquí; los demás lo leen.
;; ❌ No lo modifiques
;;==============================================================
SECTION "Frame data", WRAM0
frame_counter::  DS 1                 ;; frames counted since the start (it wraps around)

SECTION "Engine: frame", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the counter at 0.
;; ❌ Modifies A
frame_init::
   INCBIN "bin/frame_init.bin"            ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; One more frame. The main loop calls it once per frame.
;; ❌ Modifies HL
frame_tick::
   INCBIN "bin/frame_tick.bin"            ;; Rutina dada, en binario (5 bytes)
