;;==============================================================
;; Challenge 5 · Memoria
;; memcpy8, memset8, memcpy16 y call_hl
;; ❌ No lo modifiques
;;==============================================================

SECTION "Engine: memory", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = source, DE = destination, B = number of bytes (1-255)
;; ⫷▬ HL and DE have advanced B bytes
;; ❌ Modifies A, B, DE, HL
memcpy8::
   INCBIN "bin/memcpy8.bin"               ;; Rutina dada, en binario (7 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = destination, A = value, B = number of bytes (1-255)
;; ❌ Modifies B, HL
memset8::
   INCBIN "bin/memset8.bin"               ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = source, DE = destination, BC = number of bytes (1-65535)
;; ❌ Modifies A, BC, DE, HL
;; ⚠️ It is a double loop, to make each byte cheaper (10 cycles). The simpler
;;    way to test BC (dec bc / ld a, b / or c / jr nz) costs 13 cycles per byte.
memcpy16::
   INCBIN "bin/memcpy16.bin"              ;; Rutina dada, en binario (15 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jumps to the routine whose address is in HL.
;; There is no "call hl", but "call call_hl" does the same.
;; The routine's own "ret" returns to the instruction after the "call".
call_hl::
   INCBIN "bin/call_hl.bin"               ;; Rutina dada, en binario (1 bytes)
