;;==============================================================
;; Challenge 6 · Los niveles del juego
;; Un nivel son datos en la ROM: su mapa, su canción (la que suena mientras se juega, en assets/snd/),
;; dónde empieza el héroe, dónde se abre el portal cuando ya no quedan enemigos, y dónde
;; está cada enemigo. Las posiciones de los enemigos y del héroe están en TILES: hay que multiplicarlas
;; por 8 para tener píxeles. La del portal ya está en PÍXELES.
;; Para añadir un nivel: dibuja su mapa (maps.asm), elige o crea su canción,
;; escribe sus datos aquí, ponlo en LevelTable y sube NUM_LEVELS (scn_game.inc).
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Game: levels", ROM0

;; The levels, in order: the game plays them one after another
LevelTable::
   DW Level1, Level2, Level3
ASSERT (@ - LevelTable) == NUM_LEVELS * 2

;; Level 1: a meadow
Level1:
   DW Level1Map
   DW SongLevel1
   DB 4, 27                         ;; the hero starts at column 4, row 27
   DB 29 * 8, 2 * 8                 ;; the portal appears at X = 232, Y = 16 (column 29, row 2)
   DB 3                             ;; 3 enemies:
   DB 10, 18,  16, 27,  20, 19      ;; (row, column) of each one

;; Level 2: some ruins, with their rooms
Level2:
   DW Level2Map
   DW SongLevel2
   DB 2, 26
   DB 29 * 8, 3 * 8
   DB 4
   DB 5, 1,  22, 14,  12, 20,  1, 20

;; Level 3: a dungeon
Level3:
   DW Level3Map
   DW SongLevel3
   DB 3, 27
   DB 27 * 8, 18 * 8
   DB 5
   DB 23, 17,  8, 26,  3, 4,  25, 7,  24, 26
