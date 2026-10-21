;;==============================================================
;; Challenge 6 · Escena: Final épico
;; El héroe ha cruzado el último portal. Solo espera START para volver al menú.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "assets/gfx/gfx.inc"

SECTION "Scene: win", ROM0

scene_win::      DW scene_win_init, scene_win_update

txt_win:         DB "FINAL EPICO!", TEXT_END
txt_press_win:   DB "PULSA START", TEXT_END

DEF TXT_WIN_LOCATION   = TILEMAP +  6 * TILEMAP_WIDTH + 4 ;; row  6, col 4
DEF TXT_PRESS_LOCATION = TILEMAP + 10 * TILEMAP_WIDTH + 4 ;; row 10, col 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Victory scene: a text screen with its song. The screen is off.
;; ❌ Modifies A, BC, DE, HL
scene_win_init::
   call scene_text_start        ;; Nothing from the game: a blank screen

   ld   hl, txt_win             ;; \ HL = Win text 
   ld   de, TXT_WIN_LOCATION    ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, txt_press_win       ;; \ HL = Press text
   ld   de, TXT_PRESS_LOCATION  ;; | DE = tilemap location
   call text_draw               ;; /

   ld   hl, SongWin             ;; \ The victory song
   jp   sound_play_song         ;; / (and return)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Victory scene, every frame: if START has just been pressed, go to
;; the menu scene (scene_menu). If not, do nothing.
;; ❌ May modify A, BC, DE, HL
scene_win_update::
   ld   a, [input_pressed]      ;; \ A = the buttons just pressed
   and  BTN_START               ;; | Is START one of them?
   ret  z                       ;; / No: nothing to do

   ld   hl, scene_menu          ;; \ HL = the menu scene
   jp   scene_change            ;; / Change to it (and return)
