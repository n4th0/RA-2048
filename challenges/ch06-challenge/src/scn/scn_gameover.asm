;;==============================================================
;; Challenge 6 · Escena: game over
;; El héroe ha muerto. Solo espera START para volver al menú.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "assets/gfx/gfx.inc"

SECTION "Scene: game over", ROM0

scene_gameover:: DW scene_gameover_init, scene_gameover_update

txt_game_over:   DB "GAME OVER", TEXT_END
txt_press:       DB "PULSA START", TEXT_END

DEF TXT_GAMEOVER_LOCATION = TILEMAP +  6 * TILEMAP_WIDTH + 5 ;; row  6, col 5
DEF TXT_PRESS_LOCATION    = TILEMAP + 10 * TILEMAP_WIDTH + 4 ;; row 10, col 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game over scene: a text screen with its song. The screen is off.
;; ❌ Modifies A, BC, DE, HL
scene_gameover_init::
   call scene_text_start        ;; Nothing from the game: a blank screen

   ld   hl, txt_game_over       ;; \ HL = Game over text
   ld   de, TXT_GAMEOVER_LOCATION ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, txt_press           ;; \ HL = Press text
   ld   de, TXT_PRESS_LOCATION  ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, SongGameOver        ;; \ The game over song
   jp   sound_play_song         ;; / (and return)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game over scene, every frame: if START has just been pressed, go to
;; the menu scene (scene_menu). If not, do nothing.
;; Each scene only updates its own things: this one does not touch the game.
;; ❌ May modify A, BC, DE, HL
scene_gameover_update::
   ld   a, [input_pressed]      ;; \ A = the buttons just pressed
   and  BTN_START               ;; | Is START one of them?
   ret  z                       ;; / No: nothing to do

   ld   hl, scene_menu          ;; \ HL = the menu scene
   jp   scene_change            ;; / Change to it (and return)
