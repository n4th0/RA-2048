;;=============================================================================
;; rng.asm — Números aleatorios
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; rDIV ($FF04) es un contador que avanza solo muy deprisa. Leerlo a secas no
;; basta: en un mismo frame daría casi el mismo número a todas las ovejas y
;; se moverían a la vez. Por eso guardamos un estado y en cada llamada hacemos
;;     estado = estado * 5 + 1 + rDIV
;; Así cada llamada da un número distinto aunque rDIV no haya cambiado.
;;=============================================================================
INCLUDE "hardware.inc"

SECTION "RNG state", WRAM0
rng_state: DS 1

SECTION "RNG CODE", ROM0

;;-----------------------------------------------------------------------------
;; rng_init: estado inicial a partir de rDIV.
;; Modifica: A
rng_init::
   ldh a, [rDIV]
   ld [rng_state], a
   ret

;;-----------------------------------------------------------------------------
;; rng_next: siguiente número aleatorio.
;; 📤 A = número (0..255)
;; Modifica: A, F (conserva BC, DE y HL)
rng_next::
   push bc
   ld a, [rng_state]
   ld b, a                  ;; B = estado
   add a                    ;; A = estado * 2
   add a                    ;; A = estado * 4
   add b                    ;; A = estado * 5  (los 8 bits dan la vuelta: módulo 256)
   inc a                    ;; + 1
   ld b, a
   ldh a, [rDIV]
   add b                    ;; + rDIV
   ld [rng_state], a
   pop bc
   ret

;;-----------------------------------------------------------------------------
;; rng_sign: +1 o -1 al azar.
;; 📤 A = 1 o -1 ($FF)
;; Modifica: A, F
rng_sign::
   call rng_next
   bit 0, a                 ;; mirar solo un bit: mitad de veces 0, mitad 1
   ld a, 1
   ret z
   ld a, -1
   ret
