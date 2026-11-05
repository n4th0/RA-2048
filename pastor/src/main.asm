
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Entry point", ROM0[$150]

main::
   di                       

   call lcd_off

   ld hl, tiles             
   ld de, _VRAM8000
   ld bc, tiles_end - tiles
   call memcpy

   ld a, %11100100          
   ld [rBGP], a
   call sfx_init
   xor a                    
   ld [rSCY], a
   ld [rSCX], a
   ld [joypad_dpad], a      
   ld [joypad_buttons], a
   ld [joypad_pressed], a

   call record_load
   call scene_title_enter

   
.mainloop:
   call wait_vblank
   call scene_manager_update
   jr .mainloop
