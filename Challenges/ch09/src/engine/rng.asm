;;==============================================================
;; Challenge 5 · Números aleatorios
;; rng_seed y rng_next
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Random data", WRAM0
rng_state::      DS 2                 ;; random number generator (never 0)

SECTION "Engine: random", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sets the random number generator from things that are hard to
;; predict: the divider register and how long we have been in the menu.
;; ❌ Modifies A
rng_seed::
   INCBIN "bin/rng_seed.bin"              ;; Rutina dada, en binario (15 bytes)

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
   INCBIN "bin/rng_next.bin"              ;; Rutina dada, en binario (37 bytes)
