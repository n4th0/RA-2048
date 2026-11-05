INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Joypad state", WRAM0
joypad_dpad::    DS 1  
joypad_buttons:: DS 1   
joypad_pressed:: DS 1   

SECTION "Joypad CODE", ROM0


joypad_read::

   ld a, $20
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]             ;; se lee 2 veces
   and %00001111            
   xor %00001111            ;; dar la vuelta
   ld [joypad_dpad], a


   ld a, $10
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]             
   and %00001111
   xor %00001111
   ld b, a                  

   ld a, [joypad_buttons]   
   xor %00001111            
   and b
   ld [joypad_pressed], a
   ld a, b
   ld [joypad_buttons], a

   ld a, $30                
   ldh [rP1], a
   ret
