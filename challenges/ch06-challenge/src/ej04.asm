;;==============================================================
;; Challenge 6 · Ejercicio 04 · Completa map_tile_address
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej04" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `map_tile_address` está en src/man/man_map.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej04::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la posición llega ya en tiles: `D` = fila y `E` = columna. (`map_is_solid_at` sigue recibiendo píxeles: los divide entre 8 antes de llamar a esta rutina.)
;;
;;   Devuelve en `HL` la dirección del tile de una fila y una columna del mapa. El mapa es una tabla de 32 filas de 32 tiles.
;;   - 📥 `D` = fila y `E` = columna.
;;   - ⫷▬ `HL` = `map_current + fila × 32 + columna`.
;;
;;   El código dado suma `map_current` a `HL` y vuelve. Tú calculas antes, en `HL`, el offset `fila × 32 + columna`:
;;   1. `fila × 32`: multiplica la fila por 2 cinco veces, en `HL`.
;;   2. Suma la columna.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 04", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Where is the tile at a row and a column of the map?
;; The map is a table of rows of MAP_WIDTH (32) tiles:
;;      address     = map + row * 32 + column
;; 📥 D = row, E = column (in TILES: the position of the world is already divided by 8)
;; ⫷▬ HL = address of its tile in the map
;; ❌ Modifies A, HL
ej04::   ;; = `map_tile_address`, que está en src/man/man_map.asm
   ;; ◉◉YOUR CODE◉◉

   ld   a, [map_current]        ;; \ HL += map_current: the address in the map
   add  l                       ;; |
   ld   l, a                    ;; |
   ld   a, [map_current + 1]    ;; |
   adc  h                       ;; |
   ld   h, a                    ;; /

   ret

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej04 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Nivel 1: map_current = Level1Map (0188). D = 27 (fila), E = 4 (columna).
;; [CPU]
;;    hl = 04EC
;;    de = 1B04
;;  27 × 32 + 4 = 868 (364 en hexadecimal). HL = Level1Map + 364 = 04EC. DE no cambia.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Nivel 1: map_current = Level1Map (0188). D = 31 (fila), E = 31 (columna).
;; [CPU]
;;    hl = 0587
;;    de = 1F1F
;;  31 × 32 + 31 = 1023 (3FF en hexadecimal). HL = Level1Map + 3FF = 0587: el último byte del mapa. DE no cambia.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
