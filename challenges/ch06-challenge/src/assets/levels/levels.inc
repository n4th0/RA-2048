;;==============================================================
;; Challenge 6 · Los niveles del juego: estructura
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(LEVELS_INC)
DEF LEVELS_INC = 1

;; The structure of a level (the offsets of its fields).
;; The levels are in assets/levels/levels.asm
RSRESET
DEF LVL_MAP        RW 1             ;; 0  the address of its map (MAP_SIZE tiles)
DEF LVL_SONG       RW 1             ;; 2  the address of its song (sound_play_song)
DEF LVL_PLAYER_TX  RB 1             ;; 4  where the hero starts: column, row (tiles)
DEF LVL_PLAYER_TY  RB 1             ;; 5
DEF LVL_EXIT_X     RB 1             ;; 6  where the portal appears: X and Y in PIXELS
DEF LVL_EXIT_Y     RB 1             ;; 7
DEF LVL_ENEMIES    RB 1             ;; 8  how many enemies, then each TY, TX (row, col)
DEF LVL_ENEMY_LIST RB 0             ;; 9

ENDC
