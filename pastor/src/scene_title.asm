;;=============================================================================
;; scene_title.asm — Pantalla de título
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "text.inc"

DEF START_ROW     EQU 11
DEF START_ADDRESS EQU _SCRN0 + START_ROW * MAP_STRIDE + (SCREEN_W - 11) / 2  ;; "PULSA START"
DEF BLINK_FRAMES  EQU 32
DEF RECORD_ROW    EQU 14

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

   TEXT_CENTERED 4, "PASTOR"
   ld hl, _SCRN0 + 6 * MAP_STRIDE + 6   ;; un pastor y su rebaño
   ld a, TILE_SHEPHERD
   ld [hl+], a
   inc hl
   ld a, TILE_SHEEP
   ld [hl+], a
   ld [hl+], a
   inc hl
   ld [hl+], a
   inc hl
   ld [hl], a
   TEXT_CENTERED 8, "LLEVA LAS OVEJAS"
   TEXT_CENTERED 9, "AL CORRAL"
   TEXT_CENTERED START_ROW, "PULSA START"

   ld hl, _SCRN0 + RECORD_ROW * MAP_STRIDE + 3
   ld de, text_record
   call print_text          ;; "RECORD " y los 6 dígitos detrás
   ld de, record
   ld b, SCORE_BYTES
   call print_bcd

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
   bit PADB_START, a
   jp nz, scene_game_new_game

   ld hl, blink_timer
   dec [hl]
   ret nz
   ld [hl], BLINK_FRAMES
   ld hl, START_ADDRESS
   ld a, [blink_visible]
   xor 1
   ld [blink_visible], a
   jr z, .hide
   ld de, text_press_start
   jp queue_text
.hide:
   ld b, 11
   jp queue_blank

text_press_start:
   db "PULSA START", END_OF_LIST
text_record::
   db "RECORD ", END_OF_LIST
