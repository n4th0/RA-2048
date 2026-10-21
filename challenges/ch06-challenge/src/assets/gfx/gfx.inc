;;==============================================================
;; Tile IDs of the graphics (all in the $8000 tile block)
;;==============================================================
IF !DEF(GFX_INC)
DEF GFX_INC = 1

DEF NUM_TILES = 148
;; The first tiles are the font: tile = ASCII code - ASCII_TILE_OFFSET
;; (space, punctuation, digits, capitals: ASCII $20-$5F  ->  tiles 0-63)
DEF ASCII_TILE_OFFSET = $20
DEF ASCII_TILE_COUNT  = 64
DEF TILE_BLANK        = 0
DEF TILE_DIGIT_0      = 16
;; Level tiles. From TILE_FIRST_SOLID on, they are SOLID: nothing walks through them
DEF TILE_GRASS_A      = 64
DEF TILE_GRASS_B      = 65
DEF TILE_FLOWER       = 66
DEF TILE_PATH         = 67
DEF TILE_FLOOR        = 68
;; Tiles of the HUD (they never appear in a level map)
DEF TILE_HEART_FULL   = 69
DEF TILE_HEART_EMPTY  = 70
DEF TILE_ICON_ENEMY   = 71
;; Solid tiles of a level
DEF TILE_FIRST_SOLID  = 72
DEF TILE_TREE         = 72
DEF TILE_ROCK         = 73
DEF TILE_WATER        = 74
DEF TILE_WALL         = 75
DEF TILE_BRICK        = 76
;; Entity images: 16x16 pixels = 4 tiles each.
;; A sheet: 3 rows (down, up, side) of 2 images (walking steps): image = row * 2 + step
DEF TILE_PLAYER       = 80
DEF TILE_ENEMY        = 104
DEF TILE_SWORD        = 128
DEF TILE_PORTAL       = 136
DEF TILE_POOF         = 144

DEF TILES_PER_IMAGE = 4        ;; an entity image: 2 sprites of 8x16 = 4 tiles
DEF SHEET_ROW_TILES = 2 * TILES_PER_IMAGE   ;; a row of a sheet: 2 images
ENDC
