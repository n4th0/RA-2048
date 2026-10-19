;;=============================================================================
;; hud.asm — Marcador de la fila 0:  N1 T120 001230   [oveja]05
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Quien cambia un dato activa su bit en hud_dirty, y hud_update (una vez por
;; frame) encola solo lo que ha cambiado. Así, si se encierran dos ovejas en
;; el mismo frame, los dígitos no se encolan dos veces.
;;=============================================================================
INCLUDE "text.inc"

DEF HUD_LEVEL       EQU _SCRN0 + 0
DEF HUD_TIME        EQU _SCRN0 + 3
DEF HUD_SCORE       EQU _SCRN0 + 8
DEF HUD_SHEEP_ICON  EQU _SCRN0 + SCREEN_W - 3
DEF HUD_SHEEP_COUNT EQU _SCRN0 + SCREEN_W - 2

;; Tiles que puede encolar el marcador en un frame: hud_init los encola todos
DEF HUD_INIT_TILES EQU 2 + 4 + SCORE_BYTES * 2 + 3
ASSERT HUD_INIT_TILES <= HUD_MAX_TILES, "el marcador no cabe en su parte de la cola de render"

SECTION "HUD state", WRAM0
hud_dirty:: DS 1             ;; bits HUDB_*: qué repintar en el siguiente hud_update

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

   ld a, HUDF_ALL
   ld [hud_dirty], a
   ;; sigue en hud_update

;;-----------------------------------------------------------------------------
;; hud_update: encola lo marcado en hud_dirty y lo limpia.
;; Llamar una vez por frame, antes de sys_render_update.
;; Modifica: A, F, BC, DE, HL
hud_update::
   ld hl, hud_dirty
   bit HUDB_TIME, [hl]
   jr z, .score
   ld a, [time_left]        ;; 3 dígitos: del byte alto solo las unidades
   and $0F
   add TILE_DIGIT_0
   ld hl, HUD_TIME + 1
   call render_queue_push
   ld hl, HUD_TIME + 2
   ld de, time_left + 1
   ld b, 1
   call queue_bcd

.score:
   ld hl, hud_dirty
   bit HUDB_SCORE, [hl]
   jr z, .sheep
   ld hl, HUD_SCORE
   ld de, score
   ld b, SCORE_BYTES
   call queue_bcd

.sheep:
   ld hl, hud_dirty
   bit HUDB_SHEEP, [hl]
   jr z, .done
   call queue_sheep_left

.done:
   xor a
   ld [hud_dirty], a
   ret

;;-----------------------------------------------------------------------------
;; queue_sheep_left: encola los 2 dígitos de sheep_left (binario, 0..99).
;; Modifica: A, F, BC, DE, HL
queue_sheep_left:
   ld a, [sheep_left]
   ld b, TILE_DIGIT_0       ;; B = tile de las decenas
.tens:
   cp 10
   jr c, .units
   sub 10
   inc b
   jr .tens
.units:
   add TILE_DIGIT_0
   ld c, a                  ;; C = tile de las unidades

   push bc
   ld hl, HUD_SHEEP_COUNT
   ld a, b
   call render_queue_push
   pop bc
   ld hl, HUD_SHEEP_COUNT + 1
   ld a, c
   jp render_queue_push
