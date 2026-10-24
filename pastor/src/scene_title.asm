;;=============================================================================
;; scene_title.asm — Pantalla de título
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Los textos se colocan a mano: dirección = $9800 + fila * 32 + columna,
;; como en el ejemplo de la sesión 03.1. Para centrar un texto de N letras,
;; columna = (20 - N) / 2.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "charmap.inc"

DEF START_ADDRESS EQU _SCRN0 + 14 * MAP_STRIDE + 4   ;; "PULSA START" (11): columna 4
DEF START_LENGTH  EQU 11
DEF BLINK_FRAMES  EQU 32

SECTION "Scene title state", WRAM0
blink_timer:   DS 1
blink_visible: DS 1          ;; no leemos la VRAM para saberlo: fuera del VBLANK no es fiable

SECTION "Scene title CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_title_enter: dibuja el título y pasa a esta escena.
scene_title_enter::
   call lcd_off
   call sys_render_reset
   ld hl, screen_frame
   call level_load

   ld hl, _SCRN0 + 4 * MAP_STRIDE + 7     ;; "PASTOR" (6): columna 7
   ld de, text_title
   call print_text

   ld hl, _SCRN0 + 6 * MAP_STRIDE + 6     ;; un pastor y su rebaño
   ld de, title_flock
   call print_text

   ld hl, _SCRN0 + 9 * MAP_STRIDE + 1     ;; "MUEVE CON FLECHAS" (17): columna 1
   ld de, text_controls
   call print_text
   ld hl, _SCRN0 + 11 * MAP_STRIDE + 2    ;; "LLEVA LAS OVEJAS" (16): columna 2
   ld de, text_line_1
   call print_text
   ld hl, _SCRN0 + 12 * MAP_STRIDE + 5    ;; "AL CORRAL" (9): columna 5
   ld de, text_line_2
   call print_text

   ld hl, START_ADDRESS
   ld de, text_press_start
   call print_text

   ld hl, _SCRN0 + 16 * MAP_STRIDE + 3    ;; "RECORD " y 6 dígitos (13): columna 3
   ld de, text_record
   call print_text          ;; HL queda justo detrás de "RECORD "
   ld de, record
   ld b, SCORE_DIGITS
   call print_digits

   ld a, BLINK_FRAMES
   ld [blink_timer], a
   ld a, 1
   ld [blink_visible], a
   call lcd_on
   ld a, SCENE_TITLE
   ld [scene_id], a
   ret

;;-----------------------------------------------------------------------------
;; scene_title_update: hace parpadear PULSA START y espera a START.
scene_title_update::
   call sys_render_flush
   call joypad_read
   ld a, [joypad_pressed]
   bit BTN_START, a
   jp nz, scene_game_new_game

   ld hl, blink_timer
   dec [hl]
   ret nz
   ld [hl], BLINK_FRAMES
   ld a, [blink_visible]    ;; cambiar entre visible (1) e invisible (0)
   xor 1
   ld [blink_visible], a
   ld hl, START_ADDRESS
   cp 0
   jr z, .hide
   ld de, text_press_start
   jp queue_text
.hide:
   ld b, START_LENGTH
   jp queue_blank

text_title:
   db "PASTOR", END_OF_LIST
title_flock:                ;; tiles sueltos: pastor, hueco, ovejas
   db TILE_SHEPHERD, TILE_GRASS, TILE_SHEEP, TILE_SHEEP, TILE_GRASS, TILE_SHEEP, TILE_GRASS, TILE_SHEEP, END_OF_LIST
text_controls:
   db "MUEVE CON FLECHAS", END_OF_LIST
text_line_1:
   db "LLEVA LAS OVEJAS", END_OF_LIST
text_line_2:
   db "AL CORRAL", END_OF_LIST
text_press_start:
   db "PULSA START", END_OF_LIST
text_record::
   db "RECORD ", END_OF_LIST
