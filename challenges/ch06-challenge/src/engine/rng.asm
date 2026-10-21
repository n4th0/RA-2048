;;==============================================================
;; Challenge 6 · Números aleatorios
;; rng_seed y rng_next
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Random data", WRAM0
rng_state::       DS 2                 ;; random number generator (never 0)

SECTION "Engine: random", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sets the random number generator from things that are hard to
;; predict: the divider register and how long we have been in the menu.
;; ❌ Modifies A
rng_seed::
   ld   a, [rDIV]               ;; \ A = the divider register
   or   1                       ;; | (it changes all the time)
   ld   [rng_state], a          ;; / rng_state (low byte) = A | 1: it is never 0

   ld   a, [frame_counter]      ;; \ A = frames counted so far
   ld   [rng_state + 1], a      ;; / rng_state (high byte) = A

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Random number generator: xorshift of George Marsaglia, 16 bits.
;; It repeats the 16-bit state x:
;;     x = x ^ (x << 7)
;;     x = x ^ (x >> 9)
;;     x = x ^ (x << 8)
;; Those three shifts visit all 65535 non-zero values before repeating.
;; ⫷▬ A = random number (0-255)
;; ❌ Modifies A, B, HL
rng_next::
   ld   hl, rng_state           ;; \ HL = rng_state (x):
   ld   a, [hl+]                ;; |
   ld   h, [hl]                 ;; |
   ld   l, a                    ;; / H: high byte, L: low byte

   ld   a, h                    ;; \ x = x ^ (x << 7)
   srl  a                       ;; | First, x << 7: its high byte...
   ld   a, l                    ;; |
   rra                          ;; |
   ld   b, a                    ;; / ...is (H.0, L >> 1)

   ld   a, 0                    ;; \ ...and its low byte
   rra                          ;; / is (L.0, then zeros)

   xor  l                       ;; \ L ^= low byte of x << 7
   ld   l, a                    ;; /

   ld   a, b                    ;; \ H ^= high byte of x << 7
   xor  h                       ;; |
   ld   h, a                    ;; /

   ld   a, h                    ;; \ x = x ^ (x >> 9)
   srl  a                       ;; | (>> 9: the high byte >> 1,
   xor  l                       ;; | moved to the low byte)
   ld   l, a                    ;; /

   ld   a, h                    ;; \ x = x ^ (x << 8)
   xor  l                       ;; | (<< 8: the low byte,
   ld   h, a                    ;; / moved to the high byte)

   ld   a, l                    ;; \ rng_state = x
   ld   [rng_state], a          ;; |
   ld   a, h                    ;; |
   ld   [rng_state + 1], a      ;; /

   ret                          ;; A = H: the random number
