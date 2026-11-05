INCLUDE "hardware.inc"
INCLUDE "constants.inc"


SECTION "Level map", WRAM0
level_map:: DS LEVEL_SIZE

SECTION "Level code", ROM0


level_load::
   push hl                  
   ld de, level_map
   ld bc, LEVEL_SIZE
   call memcpy
   pop hl

   ld de, _SCRN0
   ld c, SCREEN_H           
.row:
   ld b, SCREEN_W           
.col:
   ld a, [hl+]
   ld [de], a
   inc de
   dec b
   jr nz, .col

   ld a, e                  
   add MAP_STRIDE - SCREEN_W
   ld e, a
   ld a, d
   adc 0                    
   ld d, a
   dec c
   jr nz, .row
   ret


level_tile_at::
   ld h, 0
   ld l, b
   add hl, hl
   add hl, hl               
   ld d, h
   ld e, l
   add hl, hl
   add hl, hl               
   add hl, de               
   ld d, 0
   ld e, c
   add hl, de               
   ld de, level_map
   add hl, de
   ld a, [hl]
   ret


level_is_blocked::
   call level_tile_at
   cp TILE_GRASS
   jr z, .check_entities
   cp TILE_CORRAL
   jr z, .check_entities
   scf                     
   ret
.check_entities:
   jp man_entity_at         
