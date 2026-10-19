;;=============================================================================
;; rng.asm — Números pseudoaleatorios (xorshift de 16 bits)
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Leer rDIV directamente no basta: en un mismo frame devuelve casi el mismo
;; valor a todas las ovejas y se moverían a la vez. rDIV solo da la semilla;
;; después, xorshift 7-9-8 (versión Z80 de John Metcalf) produce una
;; secuencia que no se repite hasta 65535 valores.
;;=============================================================================
INCLUDE "hardware.inc"

SECTION "RNG state", WRAM0
rng_state: DS 2              ;; nunca puede valer 0: xorshift se quedaría en 0

SECTION "RNG CODE", ROM0

;;-----------------------------------------------------------------------------
;; rng_init: siembra el generador con el contador rDIV.
;; Modifica: A
rng_init::
   ldh a, [rDIV]
   ld [rng_state], a
   ld a, $A5                ;; parte alta fija distinta de 0: estado nunca nulo
   ld [rng_state + 1], a
   ret

;;-----------------------------------------------------------------------------
;; rng_next: siguiente número pseudoaleatorio.
;; 📤 A = número (0..255)
;; Modifica: A, F (conserva HL)
rng_next::
   push hl
   ld hl, rng_state
   ld a, [hl+]
   ld h, [hl]
   ld l, a                  ;; HL = estado
   ld a, h                  ;; HL ^= HL << 7
   rra
   ld a, l
   rra
   xor h
   ld h, a
   ld a, l                  ;; HL ^= HL >> 9
   rra
   ld a, h
   rra
   xor l
   ld l, a
   xor h                    ;; HL ^= HL << 8
   ld h, a
   ld a, l
   ld [rng_state], a
   ld a, h
   ld [rng_state + 1], a
   pop hl
   ret

;;-----------------------------------------------------------------------------
;; rng_sign: +1 o -1 al azar.
;; 📤 A = 1 o $FF (-1)
;; Modifica: A, F
rng_sign::
   call rng_next
   and 1                    ;; 0 o 1
   add a                    ;; 0 o 2
   dec a                    ;; -1 o 1
   ret
