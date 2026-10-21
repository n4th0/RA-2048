;;==============================================================
;; Challenge 6 · Ejercicio 08 · Implementa sys_ai_choose
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej08" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_ai_choose` está en src/sys/sys_ai.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej08::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la entidad se queda quieta 1 de cada 4 veces: cuando los bits 7-6 de `A` valen 00 (`AI_STILL_MASK`). Si no, la dirección son los bits 5-4.
;;
;;   Decide qué hace una entidad a partir de un número aleatorio.
;;
;;   📥 `DE` = entidad, `A` = número aleatorio.
;;   1. Si los bits 7-6 de `A` valen 00, la entidad se queda quieta: `sys_physics_stop`.
;;   2. Si no, camina en la dirección que dicen los bits 5-4 de `A` (un número de 0 a 3, como `DIR_DOWN`, `DIR_UP`, `DIR_LEFT` y `DIR_RIGHT`): `sys_physics_walk` con `B` = esa dirección.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 08", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The AI decides what an entity does, from a random number: 1 time in 4 it stands
;; still, and the other three it walks in one of the 4 directions.
;;  - Bits 7-6 of the number at 0 (AI_STILL_MASK): stand still (sys_physics_stop).
;;  - Bits 5-4 of the number: the direction to walk (sys_physics_walk, B = direction).
;; 📥 DE = entity, A = a random number
;; ❌ Modifies A, BC, HL
ej08::   ;; = `sys_ai_choose`, que está en src/sys/sys_ai.asm
   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej08 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> A = %00110101 (bits 7-6 = 00). Entidad 0 con VY = 1, VX = 0 y mirando hacia abajo. DE = entidad 0.
;; [CPU]
;;    de = C000
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  C3 00 00 00 00 00 00 00|00 00 00 00 00 00 00 00|
;;  Los bits 7-6 valen 00: la entidad se queda quieta. VY pasa de 1 a 0; VX y DIR no cambian.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> A = %01100000 (bits 7-6 = 01, bits 5-4 = 10). Entidad 0 quieta, mirando hacia abajo. DE = entidad 0.
;; [CPU]
;;    de = C000
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  C3 00 00 00 00 00 FF 00|02 00 00 00 00 00 00 00|
;;  Los bits 7-6 valen 01 (no es 00): camina. Los bits 5-4 valen %10 = DIR_LEFT (2): DIR = 02 y VX = −1 (FF).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
