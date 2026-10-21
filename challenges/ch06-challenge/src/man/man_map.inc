;;==============================================================
;; Challenge 6 · Gestor del mapa: constantes
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(MAN_MAP_INC)
DEF MAN_MAP_INC = 1

;; The map of a level is a table of tiles, in ROM: MAP_HEIGHT rows of MAP_WIDTH tiles.
;; It is exactly the size of the background of the console (32 x 32 tiles), so
;; the same bytes are copied to the screen and used to know what is solid.
DEF MAP_WIDTH   = 32                 ;; tiles
DEF MAP_HEIGHT  = 32
DEF MAP_SIZE    = MAP_WIDTH * MAP_HEIGHT
DEF TILE_SIZE   = 8                  ;; a tile is 8 x 8 pixels
DEF MAP_PIXELS  = MAP_WIDTH * TILE_SIZE ;; 256: the world is 256 x 256 pixels, so a
                                     ;; position (Y or X) fits in ONE byte

ENDC
