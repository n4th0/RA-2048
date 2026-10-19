;;=============================================================================
;; levels.asm — Mapas de los niveles (datos en ROM)
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Cada nivel son 18 filas de 20 caracteres. CHARMAP traduce cada carácter
;; a su índice de tile, así el nivel se edita como un dibujo:
;;    " " blanco (fila 0, reservada para el marcador)
;;    "." hierba     "#" valla     ":" suelo del corral
;; Pastor y ovejas NO van en el mapa: son entidades. Cada nivel tiene además
;; una lista de "spawns" con su posición inicial (ver level_1_spawns).
;;=============================================================================
INCLUDE "constants.inc"

CHARMAP " ", TILE_BLANK
CHARMAP ".", TILE_GRASS
CHARMAP "#", TILE_FENCE
CHARMAP ":", TILE_CORRAL

SECTION "Levels", ROM0

level_1::
   db "                    "   ;;  0 marcador
   db "####################"   ;;  1
   db "#..................#"   ;;  2
   db "#..................#"   ;;  3
   db "#...###............#"   ;;  4
   db "#..................#"   ;;  5
   db "#.........#........#"   ;;  6
   db "#.........#........#"   ;;  7
   db "#..................#"   ;;  8
   db "#..................#"   ;;  9
   db "#............##::###"   ;; 10 entrada del corral (columnas 15-16)
   db "#............#:::::#"   ;; 11
   db "#............#:::::#"   ;; 12
   db "#............#:::::#"   ;; 13
   db "#............#:::::#"   ;; 14
   db "#............#:::::#"   ;; 15
   db "#............#:::::#"   ;; 16
   db "####################"   ;; 17
level_1_end:

;; Una fila con un carácter de más o de menos descuadraría todo el mapa:
;; mejor que falle el ensamblado.
ASSERT level_1_end - level_1 == LEVEL_SIZE, "level_1 no mide 20x18"

;; Posiciones iniciales: primero el pastor, después las ovejas (fila, columna).
;; La lista acaba en el centinela END_OF_LIST. Máximo MAX_ENTITIES - 1 ovejas.
;; Cada posición tiene que caer en hierba o corral, nunca en una valla.
level_1_spawns::
   db  8,  4                ;; pastor
   db  3, 10                ;; ovejas
   db  6, 15
   db  8, 12
   db 13,  5
   db 15,  9
   db END_OF_LIST

;;-----------------------------------------------------------------------------
;; Nivel 2: 7 ovejas. Corral arriba en el centro, entrada hacia abajo.
;; Hay que subirlas: las que se peguen a la valla de arriba se llevan por las
;; paredes del corral (columnas 6 y 14) hasta la fila 6.
level_2::
   db "                    "   ;;  0 marcador
   db "####################"   ;;  1
   db "#......#:::::#.....#"   ;;  2
   db "#......#:::::#.....#"   ;;  3
   db "#......#:::::#.....#"   ;;  4
   db "#......###::##.....#"   ;;  5 entrada del corral (columnas 10-11)
   db "#..................#"   ;;  6
   db "#....##......##....#"   ;;  7
   db "#..................#"   ;;  8
   db "#..#............#..#"   ;;  9
   db "#..#....####....#..#"   ;; 10
   db "#..#............#..#"   ;; 11
   db "#..................#"   ;; 12
   db "#....##......##....#"   ;; 13
   db "#..................#"   ;; 14
   db "#..................#"   ;; 15
   db "#..................#"   ;; 16
   db "####################"   ;; 17
level_2_end:
ASSERT level_2_end - level_2 == LEVEL_SIZE, "level_2 no mide 20x18"

level_2_spawns::
   db 15,  9                ;; pastor
   db  8,  3                ;; ovejas
   db  8, 16
   db 12,  6
   db 12, 13
   db 14,  3
   db 14, 16
   db  8,  9
   db END_OF_LIST

;;-----------------------------------------------------------------------------
;; Nivel 3: 9 ovejas. Corral en el centro, entrada por la izquierda, y un
;; pasillo de 1 casilla entre el corral y la pared derecha.
;; Como el corral no toca la valla exterior, una oveja pegada a ella solo
;; podría dar vueltas por el borde. Los dos espigones (filas 2 y 16) lo evitan:
;; empujada contra uno, resbala hacia el prado. tests/level_check.py lo comprueba.
level_3::
   db "                    "   ;;  0 marcador
   db "####################"   ;;  1
   db "#.........#........#"   ;;  2 espigón: despega de la valla a las ovejas
   db "#..###........###..#"   ;;  3
   db "#..................#"   ;;  4
   db "#.......#..........#"   ;;  5
   db "#.......#..........#"   ;;  6
   db "#..........#######.#"   ;;  7
   db "#..##......#:::::#.#"   ;;  8
   db "#..........::::::#.#"   ;;  9 entrada del corral (columna 11, filas 9-10)
   db "#..........::::::#.#"   ;; 10
   db "#..##......#:::::#.#"   ;; 11
   db "#..........#######.#"   ;; 12
   db "#.......#..........#"   ;; 13
   db "#.......#..........#"   ;; 14
   db "#..###........###..#"   ;; 15
   db "#........#.........#"   ;; 16 espigón
   db "####################"   ;; 17
level_3_end:
ASSERT level_3_end - level_3 == LEVEL_SIZE, "level_3 no mide 20x18"

level_3_spawns::
   db 14, 10                ;; pastor
   db  2,  5                ;; ovejas
   db  2, 15
   db  4, 10
   db  6,  4
   db  6, 15
   db 10,  6
   db 13, 15
   db 15,  9
   db 16,  4
   db END_OF_LIST

;;-----------------------------------------------------------------------------
;; Tabla de niveles: mapa, spawns y tiempo en segundos (BCD de 3 dígitos).
;; Tiempos elegidos con el bot de tests/bot.py: tarda unos 35, 40 y 90 s en el
;; peor caso; una persona necesita bastante más margen.
level_table::
   dw level_1, level_1_spawns
   db $01, $20              ;; 120 s
   dw level_2, level_2_spawns
   db $01, $50              ;; 150 s
   dw level_3, level_3_spawns
   db $02, $10              ;; 210 s
level_table_end:
ASSERT level_table_end - level_table == NUM_LEVELS * LEVEL_ENTRY_SIZE, "level_table no cuadra con NUM_LEVELS"

;;-----------------------------------------------------------------------------
;; Fondo de las pantallas de título y mensajes: prado con valla
screen_frame::
   db "                    "
   db "####################"
   REPT 15
   db "#..................#"
   ENDR
   db "####################"
screen_frame_end:
ASSERT screen_frame_end - screen_frame == LEVEL_SIZE, "screen_frame no mide 20x18"
