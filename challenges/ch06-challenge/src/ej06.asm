;;==============================================================
;; Challenge 6 · Ejercicio 06 · Completa game_enemies_spawn
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej06" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `game_enemies_spawn` está en src/scn/scn_game_rules.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej06::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la posición de cada enemigo va como fila y columna (al revés).
;;
;;   Crea los enemigos a partir de la información de un nivel.
;;
;;   📥 `HL` = dirección del campo `LVL_ENEMIES` del nivel. Ahí hay un byte con cuántos enemigos son, seguido de sus posiciones: dos bytes por enemigo (fila y columna, en tiles). Ejemplo:
;;   ```
;;   -> Con HL = 10A2
;;   -> 3 enemigos en (fila, columna), en decimal: (7, 20), (16, 26), (30, 5)
;;
;;   MEM  |  0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 |  A | ..
;;   10A0 | .. | .. | 03 | 07 | 14 | 10 | 1A | 1E | 05 | .. | .. | ..
;;   ```
;;
;;   El código dado, igual que en el entrenamiento, guarda el número de enemigos en `enemies_left`, deja en `DE` la dirección de sus posiciones y termina si no hay ninguno. Al seguir, `A` = el número de enemigos. Tú escribes el bucle:
;;   1. Para cada enemigo, crea una entidad desde `EnemyTemplate` en su columna y su fila, con `game_spawn_at` (`C` = columna, `B` = fila).
;;
;; PISTAS
;;   - `game_spawn_at` modifica `A`, `BC` y `HL`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 06", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates the enemies of a level. In the level data, a byte with how many they are
;; is followed by the position of each one: its ROW and its COLUMN, in tiles.
;; It also remembers how many there are (enemies_left).
;; 📥 HL = &level.ENEMIES
;; ❌ Modifies A, BC, DE, HL
;; ⚠️ Use game_spawn_at, with EnemyTemplate
ej06::   ;; = `game_enemies_spawn`, que está en src/scn/scn_game_rules.asm
   ld   a, [hl+]                ;; \ enemies_left = the number of enemies
   ld   [enemies_left], a       ;; | (HL -> their positions)
   ld   d, h                    ;; | DE = the positions
   ld   e, l                    ;; /
   or   a                       ;; \ No enemies? Nothing else to do
   ret  z                       ;; /

   ;; ◉◉YOUR CODE◉◉
   ld b, a

   .loop:
      push bc
      ld a, [de]
      inc de
      ld b, a

      ld a, [de]
      inc de
      ld c, a

      ld hl, EnemyTemplate
      call game_spawn_at
      pop bc
      dec b
      jr nz, .loop
      ret
;; ==========================================================
;;  ENSAMBLA: SI  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej06 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Los datos (en tst_data) son 3, (3, 2), (4, 20), (30, 9): tres enemigos como pares fila, columna. No hay entidades. HL = tst_data.
;; [MEM] enemies_left (1 byte)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0C0  .. 03 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (48 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  E7 18 10 68 00 00 00 04|00 68 00 00 01 00 00 00|
;;   C010  E7 20 A0 68 00 00 00 04|00 68 00 00 01 00 00 00|
;;   C020  E7 F0 48 68 00 00 00 04|00 68 00 00 01 00 00 00|
;;  enemies_left = 3. Tres enemigos, en el orden de los datos, con Y = fila × 8 y X = columna × 8. Primero (fila 3, columna 2): Y = 24 (18), X = 16 (10). Segundo (4, 20): Y = 32 (20), X = 160 (A0). Tercero (30, 9): Y = 240 (F0), X = 72 (48). El resto de cada entidad viene de EnemyTemplate.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Los datos son un solo byte: 0. enemies_left vale 99. HL = tst_data.
;; [MEM] enemies_left (1 byte)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0C0  .. 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  00 00 00 00 00 00 00 00|00 00 00 00 00 00 00 00|
;;  enemies_left = 0 y no se crea ninguna entidad.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
