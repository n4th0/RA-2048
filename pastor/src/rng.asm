INCLUDE "hardware.inc"

SECTION "RNG state", WRAM0
rng_state: DS 1

SECTION "RNG CODE", ROM0


rng_init::
   ldh a, [rDIV]
   ld [rng_state], a
   ret


rng_next::
   push bc
   ld a, [rng_state]
   ld b, a                  
   add a                    
   add a                   
   add b                    
   inc a                   
   ld b, a
   ldh a, [rDIV]
   add b                    
   ld [rng_state], a
   pop bc
   ret



rng_sign::
   call rng_next
   bit 0, a                 
   ld a, 1
   ret z
   ld a, -1
   ret
