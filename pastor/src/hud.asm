;;=============================================================================
;; hud.asm — Marcador de la fila 0:  N1 T120 001230   [oveja]05
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Quien cambie el tiempo, los puntos o las ovejas pone hud_dirty = 1, y
;; hud_update (una vez por frame) repinta los números. Así, si se encierran
;; dos ovejas en el mismo frame, el marcador se encola una sola vez.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"

;; Posiciones en la fila 0 (dirección = $9800 + columna)
DEF HUD_LEVEL       EQU _SCRN0 + 0    ;; "N" y el número de nivel
DEF HUD_TIME        EQU _SCRN0 + 3    ;; "T" y 3 dígitos
DEF HUD_SCORE       EQU _SCRN0 + 8    ;; 6 dígitos
DEF HUD_SHEEP_ICON  EQU _SCRN0 + 17   ;; icono de oveja
DEF HUD_SHEEP_COUNT EQU _SCRN0 + 18   ;; 2 dígitos

;; hud_init encola 4 tiles fijos + hud_update 11 números = 15 <= HUD_MAX_TILES

SECTION "HUD state", WRAM0
hud_dirty::  DS 1            ;; 1 = repintar los números en el próximo hud_update
sheep_digits: DS 2           ;; sheep_left convertido a 2 dígitos

SECTION "HUD CODE", ROM0

hud_level_text:
   db "N", END_OF_LIST
hud_time_text:
   db "T", END_OF_LIST

;;-----------------------------------------------------------------------------
;; hud_init: encola el marcador completo. Llamar al empezar cada nivel,
;; después de crear las entidades.
;; Modifica: A, F, BC, DE, HL
hud_init::
   ld hl, HUD_LEVEL
   ld de, hud_level_text
   call queue_text
   ld a, [current_level]    ;; el nivel se muestra desde 1
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

   ld a, 1                  ;; y los números
   ld [hud_dirty], a
   jr hud_update

;;-----------------------------------------------------------------------------
;; hud_update: si hud_dirty = 1, encola tiempo, puntos y ovejas.
;; Llamar una vez por frame, antes de sys_render_update.
;; Modifica: A, F, BC, DE, HL
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

   ;; sheep_left (0..99) a 2 dígitos: decenas = cuántas veces cabe 10
   ld a, [sheep_left]
   ld b, 0                  ;; B = decenas
.tens:
   cp 10
   jr c, .units
   sub 10
   inc b
   jr .tens
.units:
   ld [sheep_digits + 1], a ;; lo que queda son las unidades
   ld a, b
   ld [sheep_digits], a

   ld hl, HUD_SHEEP_COUNT
   ld de, sheep_digits
   ld b, 2
   jp queue_digits
