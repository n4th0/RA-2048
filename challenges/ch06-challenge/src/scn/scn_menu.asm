;;==============================================================
;; Challenge 6 · Escena: menú
;; Título e instrucciones. Cuando se pulsa START (o A), empieza la partida.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "assets/gfx/gfx.inc"

SECTION "Scene: menu", ROM0

;; Each scene: DW init, update    (see scene_change)
scene_menu::     DW scene_menu_init, scene_menu_update

txt_title:       DB "CHELDA", TEXT_END
txt_move:        DB "CRUZ: MOVER", TEXT_END
txt_sword:       DB "A: ESPADA", TEXT_END
txt_start:       DB "START: JUGAR", TEXT_END

DEF TXT_TITLE_LOCATION = TILEMAP +  4 * TILEMAP_WIDTH + 7 ;; row  4, col 7
DEF TXT_MOVE_LOCATION  = TILEMAP +  9 * TILEMAP_WIDTH + 4 ;; row  9, col 4
DEF TXT_SWORD_LOCATION = TILEMAP + 11 * TILEMAP_WIDTH + 4 ;; row 11, col 4
DEF TXT_START_LOCATION = TILEMAP + 14 * TILEMAP_WIDTH + 4 ;; row 14, col 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu scene: title and instructions. The screen is off.
;; ❌ Modifies A, BC, DE, HL
scene_menu_init::
   call scene_text_start        ;; Nothing from before: a blank screen

   ld   hl, txt_title           ;; \ HL = Title text
   ld   de, TXT_TITLE_LOCATION  ;; | DE = tilemap location
   call text_draw               ;; / Write it in the tilemap

   ld   hl, txt_move            ;; \ HL = Move instruction
   ld   de, TXT_MOVE_LOCATION   ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, txt_sword           ;; \ HL = Sword instruction
   ld   de, TXT_SWORD_LOCATION  ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, txt_start           ;; \ HL = Start instruction
   ld   de, TXT_START_LOCATION  ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, SongTitle           ;; \ The title song
   jp   sound_play_song         ;; / (and return)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu scene, every frame: if START or A has just been pressed, start a new game
;; (the first level) and go to the game scene (scene_game). If not, do nothing.
;; ⚠️ Use input_pressed (the "edge") and scene_change
;; ❌ May modify A, BC, DE, HL
scene_menu_update::
   ld   a, [input_pressed]      ;; \ A = the buttons just pressed
   and  BTN_START | BTN_A       ;; | Is START or A one of them?
   ret  z                       ;; / No: nothing to do

   call game_new                ;; A new game: the first level, all the hearts

   ld   hl, scene_game          ;; \ HL = the game scene
   jp   scene_change            ;; / Change to it (and return)
