;;==============================================================
;; Challenge 6 · Ejercicio 07 · Implementa portal_spawn
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej07" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `portal_spawn` está en src/scn/scn_game_rules.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej07::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la posición del portal está en los datos del nivel en píxeles (`LVL_EXIT_X` y `LVL_EXIT_Y`), no en tiles. `game_spawn_at` multiplica por 8: aquí no sirve.
;;
;;   Abre el portal del nivel actual, donde dicen sus datos.
;;   1. Crea el portal copiando `PortalTemplate` con `man_entity_create`. Si no hay hueco (`NZ`), termina.
;;   2. Calcula `HL` = `&nivel.EXIT_X`: `level_get` te da el nivel y `LVL_EXIT_X` su offset. Los datos del nivel están en la ROM y no están alineados: suma el offset a los 16 bits del `nivel`.
;;   3. Lee la X y la Y del portal (2 bytes seguidos en ROM).
;;   4. Escribe `Y` y `X` en la entidad nueva.
;;
;;   Modifica `A`, `BC`, `DE` y `HL`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 07", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Opens the portal of the level, where its data say: its X and its Y are in PIXELS.
;; ❌ Modifies A, BC, DE, HL
ej07::   ;; = `portal_spawn`, que está en src/scn/scn_game_rules.asm
   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej07 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Nivel 3 (level_current = 2): su portal está en X = 216, Y = 144. No hay entidades.
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  A5 90 D8 88 00 00 00 08|00 88 00 00 00 00 00 00|
;;  El portal se crea en la entidad 0 con los valores de PortalTemplate, Y = 144 (90) y X = 216 (D8).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Nivel 3. Las 12 entidades están vivas (solo CMP = 80).
;; [MEM] entity_array (32 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  80 00 00 00 00 00 00 00|00 00 00 00 00 00 00 00|
;;   C010  80 00 00 00 00 00 00 00|00 00 00 00 00 00 00 00|
;;  No hay hueco: no se crea nada y no se escribe nada. Las entidades siguen con CMP = 80.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
