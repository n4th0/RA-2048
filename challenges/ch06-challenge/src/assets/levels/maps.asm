;;==============================================================
;; Challenge 6 · Los mapas de los niveles
;;
;; Cada mapa son 32 x 32 tiles, dibujados con caracteres. El ensamblador los
;; convierte en los números de tile con CHARMAP, así que el mapa se VE tal como es.
;; Se puede editar a mano: cada carácter es un tile.
;; ⚠️ Los tiles sólidos (árbol, roca, agua, muro, ladrillo) no se pueden atravesar
;;==============================================================
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_map.inc"

;; The characters of the maps. Only this file uses this charmap.
NEWCHARMAP level_map
   CHARMAP ".", TILE_GRASS_A      ;; walkable
   CHARMAP ",", TILE_GRASS_B
   CHARMAP "*", TILE_FLOWER
   CHARMAP "=", TILE_PATH
   CHARMAP "_", TILE_FLOOR
   CHARMAP "T", TILE_TREE         ;; SOLID
   CHARMAP "R", TILE_ROCK
   CHARMAP "~", TILE_WATER
   CHARMAP "#", TILE_WALL
   CHARMAP "B", TILE_BRICK

SECTION "Level maps", ROM0

;; Level1
Level1Map::
   DB "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
   DB "T.................,.....RRRRRRRT"
   DB "T...*.......,..*...,,..,.=====.T"
   DB "T,.....................*.=====.T"
   DB "T..*....*..,..........,..=====.T"
   DB "T....TTT........,........=====.T"
   DB "T,...TTT....,.TTT...,..*.=====.T"
   DB "T....TTT......TTT..*........==.T"
   DB "T....,.,..,...TTT..,...,..,.==.T"
   DB "T.................,.TTT,...,==.T"
   DB "T.,..............,..TTT.....==,T"
   DB "T...............,.,.TTT,...,==.T"
   DB "T.,TT.....,..R,R.....=========.T"
   DB "T..TT........~~~~~...=========,T"
   DB "T..TT,..,...~~~~~~~..==..TTT...T"
   DB "T..TT......R~~~~~~~R.==..TTT...T"
   DB "T.....,,.,..~~~~~~~..==....,,..T"
   DB "T.....*..==============........T"
   DB "T...*....==============..*.....T"
   DB "T......TT==.*..,....,.........,T"
   DB "T.....,TT==..,,..........,.....T"
   DB "T....*.TT==...,,......TTTTT....T"
   DB "T.,.,....==,.........,TTTTT....T"
   DB "T........==..........,TTTTT....T"
   DB "T*..=======.,,.TT......,.....,.T"
   DB "T...=======,...TT...........TT.T"
   DB "T...==.....TTT..*......,....TT,T"
   DB "T...==.....TTT.,............TT.T"
   DB "T...==.,...TTT,,..,.........TT.T"
   DB "T...........,..............,...T"
   DB "T.......,..*,............*....,T"
   DB "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT"
ASSERT @ - Level1Map == MAP_SIZE

;; Level2
Level2Map::
   DB "################################"
   DB "#...,.=,#.....*.#.......#.,....#"
   DB "#....R,.#..,,,..#.......#,..,R=#"
   DB "#..R.,..=.,,....=..,....=.....=#"
   DB "#...R*..=....,..=....=RR==,..,.#"
   DB "#.......=....=.,=..,,.RR=.....=#"
   DB "#.,...=.#,R,.,..#.=.....#,,....#"
   DB "#.=*.,..#.......#...,...#.,=.,.#"
   DB "###===#############===#####===##"
   DB "#.,...,.#.....,.#.......#...*..#"
   DB "#=....,.#.,,....#.,.....#...,==#"
   DB "#......,=....R..#,.*....=..,*.,#"
   DB "#....,.,=,..RR.,#.*,....=,..,R.#"
   DB "#...=...=...RR..#.......=,.....#"
   DB "#....=..#..=.=,.#...,...#,...*,#"
   DB "#.......#.......#.......#.....=#"
   DB "###===#####===#############===##"
   DB "#.......#.......#.*.....#......#"
   DB "#..R,,..#.......#.....*.#.=.,..#"
   DB "#..,.,,,=...=..,=...R...#.=....#"
   DB "#.....,.=.......=.,.....#......#"
   DB "#..==...=.....=.=,...,..#...*.,#"
   DB "#.,..,.=#..,....#,.=,...#...=R.#"
   DB "#.......#......,#..,=...#......#"
   DB "###===#############===#####===##"
   DB "#....,..#....,,.#.......#.*....#"
   DB "#.......#.......#..R..=.#......#"
   DB "#.....,.=....,.*=.,.....=......#"
   DB "#....,,.=.....=,=...=...=..,...#"
   DB "#,......=.,...=.=...,...=......#"
   DB "#.......#..,..,.#.......#..,.,=#"
   DB "################################"
ASSERT @ - Level2Map == MAP_SIZE

;; Level3
Level3Map::
   DB "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
   DB "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
   DB "BB___________________BR______BBB"
   DB "BB___________________B_______BBB"
   DB "BB___________________B_______BBB"
   DB "BB___BBBBBBBBB___B___BBBBB___BBB"
   DB "BB____R__B___B___BR__________BBB"
   DB "BB_______B___B___B___________BBB"
   DB "BB_______B___B___B___________BBB"
   DB "BBBBBB___B___B___BBBBBBBBB___BBB"
   DB "BBR___R___R__BR______B___BR__BBB"
   DB "BB___________B_______B___B___BBB"
   DB "BB___________B_______B___B___BBB"
   DB "BBBBBBBBBB___BBBBB___B___B___BBB"
   DB "BB_______B___B_______B____R__BBB"
   DB "BB_______B___B_______B_______BBB"
   DB "BB_______B___B_______B_______BBB"
   DB "BB___B___BBBBB___BBBBB___BBBBBBB"
   DB "BB___B____R___R__B_______B___BBB"
   DB "BB___B___________B_______B___BBB"
   DB "BB___B___________B_______B___BBB"
   DB "BB___BBBBBBBBBBBBB___BBBBB___BBB"
   DB "BB___B_______________B_______BBB"
   DB "BB___B_______________B_______BBB"
   DB "BB___B_______________B_______BBB"
   DB "BB___B___BBBBBBBBBBBBBBBBB___BBB"
   DB "BB___B________________R______BBB"
   DB "BB___B_______________________BBB"
   DB "BB___B_______________________BBB"
   DB "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
   DB "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
   DB "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
ASSERT @ - Level3Map == MAP_SIZE
