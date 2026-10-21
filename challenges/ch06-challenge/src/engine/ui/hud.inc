;;==============================================================
;; Challenge 6 · HUD: corazones, nivel y enemigos
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(HUD_INC)
DEF HUD_INC = 1

INCLUDE "engine/hardware.inc"

;; The HUD lives in the WINDOW: a layer that is drawn over the background and does
;; NOT scroll. Here it is a strip of one row of tiles (8 pixels) at the bottom of
;; the screen.
DEF HUD_WINDOW_X  = 7                      ;; rWX: window at column 0 (WX = column + 7)
DEF HUD_WINDOW_Y  = SCREEN_HEIGHT - 8      ;; rWY: the last row of tiles of the screen
DEF HUD_HIDDEN_Y  = SCREEN_HEIGHT          ;; rWY below the screen: no window

DEF HUD_HEARTS_CELL = WINDOW_MAP + 1       ;; the hearts: 3 cells
DEF HUD_LEVEL_CELL  = WINDOW_MAP + 6       ;; the word NIVEL and its number
DEF HUD_ENEMY_CELL  = WINDOW_MAP + 15      ;; an enemy icon, an X and how many are left

ENDC
