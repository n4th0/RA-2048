INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"


DEF HUD_LEVEL       EQU _SCRN0 + 0   
DEF HUD_TIME        EQU _SCRN0 + 3    
DEF HUD_SCORE       EQU _SCRN0 + 8    
DEF HUD_SHEEP_ICON  EQU _SCRN0 + 17   
DEF HUD_SHEEP_COUNT EQU _SCRN0 + 18   



SECTION "HUD state", WRAM0
hud_dirty::  DS 1            
sheep_digits: DS 2           

SECTION "HUD CODE", ROM0

hud_level_text:
   db "N", END_OF_LIST
hud_time_text:
   db "T", END_OF_LIST


hud_init::
   ld hl, HUD_LEVEL
   ld de, hud_level_text
   call queue_text
   ld a, [current_level]    
   inc a
   add TILE_DIGIT_0
   ld hl, HUD_LEVEL + 1
   call render_queue_push

   ld hl, HUD_TIME
   ld de, hud_time_text
   call queue_text

   ld hl, HUD_SHEEP_ICON
   ld a, TILE_SHEEP
   call render_queue_push

   ld a, 1                  
   ld [hud_dirty], a
   jr hud_update


hud_update::
   ld a, [hud_dirty]
   cp 0
   ret z
   xor a
   ld [hud_dirty], a

   ld hl, HUD_TIME + 1
   ld de, time_left
   ld b, TIME_DIGITS
   call queue_digits

   ld hl, HUD_SCORE
   ld de, score
   ld b, SCORE_DIGITS
   call queue_digits

   ;; sheep_left (0..99) a 2 dígitos: decenas
   ld a, [sheep_left]
   ld b, 0                  
.tens:
   cp 10
   jr c, .units
   sub 10
   inc b
   jr .tens
.units:
   ld [sheep_digits + 1], a 
   ld a, b
   ld [sheep_digits], a

   ld hl, HUD_SHEEP_COUNT
   ld de, sheep_digits
   ld b, 2
   jp queue_digits
