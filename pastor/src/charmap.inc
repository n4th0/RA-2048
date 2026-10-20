;;=============================================================================
;; charmap.inc — Traducción de caracteres a índices de tile
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Con CHARMAP, `db "PASTOR"` o `db "#..#"` se ensamblan directamente como
;; índices de tile: los mapas y los textos se escriben como si fueran dibujos.
;; Incluir DESPUÉS de constants.inc.
;;   Mapas:  " " blanco  "." hierba  "#" valla  ":" corral
;;   Textos: A..Z (sin tildes ni Ñ), 0..9 y espacio
;;=============================================================================

CHARMAP " ", TILE_BLANK
CHARMAP ".", TILE_GRASS
CHARMAP "#", TILE_FENCE
CHARMAP ":", TILE_CORRAL

CHARMAP "0", TILE_DIGIT_0 + 0
CHARMAP "1", TILE_DIGIT_0 + 1
CHARMAP "2", TILE_DIGIT_0 + 2
CHARMAP "3", TILE_DIGIT_0 + 3
CHARMAP "4", TILE_DIGIT_0 + 4
CHARMAP "5", TILE_DIGIT_0 + 5
CHARMAP "6", TILE_DIGIT_0 + 6
CHARMAP "7", TILE_DIGIT_0 + 7
CHARMAP "8", TILE_DIGIT_0 + 8
CHARMAP "9", TILE_DIGIT_0 + 9

CHARMAP "A", TILE_FONT_A + 0
CHARMAP "B", TILE_FONT_A + 1
CHARMAP "C", TILE_FONT_A + 2
CHARMAP "D", TILE_FONT_A + 3
CHARMAP "E", TILE_FONT_A + 4
CHARMAP "F", TILE_FONT_A + 5
CHARMAP "G", TILE_FONT_A + 6
CHARMAP "H", TILE_FONT_A + 7
CHARMAP "I", TILE_FONT_A + 8
CHARMAP "J", TILE_FONT_A + 9
CHARMAP "K", TILE_FONT_A + 10
CHARMAP "L", TILE_FONT_A + 11
CHARMAP "M", TILE_FONT_A + 12
CHARMAP "N", TILE_FONT_A + 13
CHARMAP "O", TILE_FONT_A + 14
CHARMAP "P", TILE_FONT_A + 15
CHARMAP "Q", TILE_FONT_A + 16
CHARMAP "R", TILE_FONT_A + 17
CHARMAP "S", TILE_FONT_A + 18
CHARMAP "T", TILE_FONT_A + 19
CHARMAP "U", TILE_FONT_A + 20
CHARMAP "V", TILE_FONT_A + 21
CHARMAP "W", TILE_FONT_A + 22
CHARMAP "X", TILE_FONT_A + 23
CHARMAP "Y", TILE_FONT_A + 24
CHARMAP "Z", TILE_FONT_A + 25
