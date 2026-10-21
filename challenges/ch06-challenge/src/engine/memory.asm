;;==============================================================
;; Challenge 6 · Memoria
;; memcpy8, memset8, memcpy16 y call_hl
;; ❌ No lo modifiques
;;==============================================================

SECTION "Engine: memory", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = source, DE = destination, B = number of bytes (1-255)
;; ⫷▬ HL and DE have advanced B bytes
;; ❌ Modifies A, B, DE, HL
memcpy8::
.loop
   ld   a, [hl+]
   ld   [de], a
   inc  de
   dec  b
   jr   nz, .loop
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = destination, A = value, B = number of bytes (1-255)
;; ❌ Modifies B, HL
memset8::
.loop
   ld   [hl+], a
   dec  b
   jr   nz, .loop
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 HL = source, DE = destination, BC = number of bytes (1-65535)
;; ❌ Modifies A, BC, DE, HL
;; ⚠️ It is a double loop, to make each byte cheaper (10 cycles). The simpler
;;    way to test BC (dec bc / ld a, b / or c / jr nz) costs 13 cycles per byte.
memcpy16::
   dec  c                 ;; \  If C is not 0, the outer loop (B) needs
   inc  c                 ;; |  one more round for the first, partial
   jr   z, .loop          ;; |  pass over C bytes.
   inc  b                 ;; /
.loop
   ld   a, [hl+]          ;; \ Copy 1 byte and increment pointers
   ld   [de], a           ;; | *(DE) = *(HL); HL++; DE++;
   inc  de                ;; / 
   
   dec  c                 ;; \
   jr   nz, .loop         ;; |
   dec  b                 ;; | while (--BC != 0)
   jr   nz, .loop         ;; /
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jumps to the routine whose address is in HL.
;; There is no "call hl", but "call call_hl" does the same.
;; The routine's own "ret" returns to the instruction after the "call".
call_hl::
   jp   hl
