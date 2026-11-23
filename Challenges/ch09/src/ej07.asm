;;==============================================================
;; Challenge 5 · Ejercicio 07 · sys_prerender_update: ocultar solo lo que sobra
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej07" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_prerender_update` está en src/sys/sys_prerender.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej07::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: primero recorre las entidades y DESPUÉS oculta los sprites que no se han escrito: desde `shadow_cursor` hasta `SHADOW_OAM_SIZE` (32 bytes: 4 por entidad). `shadow_cursor` ocupa UN byte, como en el ejercicio 6.
;;   Ocultar un sprite es poner su `Y` a 0 (un byte de cada 4). No hace falta vaciarlo entero.
;;
;; PISTAS
;;   - Cada sprite ocupa 4 bytes: suma 4 a `L` para pasar al siguiente (`shadow_oam` está alineada a 256).
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 07", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prepares the whole shadow OAM (in RAM, so no hurry and no need for VBLANK):
;;  1. Puts shadow_cursor at the start of the shadow OAM.
;;  2. Prepares every entity with sys_prerender_one.
;;  3. Hides the sprites that have not been written in this pass, from shadow_cursor
;;     to the end of the sprites of the entities (SHADOW_OAM_SIZE): a sprite is hidden
;;     with Y = 0, so it is enough to set the Y of each one (every 4 bytes) to 0.
;;     This way the entities that no longer exist do not leave sprites behind.
;; ❌ May modify A, BC, DE, HL
;; ⚠️ Use man_entity_for_each
ej07::   ;; = `sys_prerender_update`, que está en src/sys/sys_prerender.asm
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
;; [PREVIO]> Entidades 0 (nave) y 2 (asteroide) con SPRITE. La OAM sombra, llena de EE (32 bytes). shadow_cursor vale 14 (le queda el valor de la pasada anterior).
;; [CPU]
;; [MEM] shadow_oam (32 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  3C 46 4E 00 90 54 4B 00|00 EE EE EE 00 EE EE EE|
;;   C010  00 EE EE EE 00 EE EE EE|00 EE EE EE 00 EE EE EE|
;; [MEM] shadow_cursor (1 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  .. 08 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Los 2 sprites ocupan los 8 primeros bytes. Los 6 sprites que sobran se ocultan con SOLO su Y = 00 (cada 4 bytes); el resto de sus bytes sigue en EE. shadow_cursor = 08 (valía 14, pero la rutina lo pone a 00 al empezar).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Ninguna entidad viva. La OAM sombra, llena de EE (32 bytes).
;; [CPU]
;; [MEM] shadow_oam (32 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  00 EE EE EE 00 EE EE EE|00 EE EE EE 00 EE EE EE|
;;   C010  00 EE EE EE 00 EE EE EE|00 EE EE EE 00 EE EE EE|
;; [MEM] shadow_cursor (1 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  .. 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Se ocultan los 8 sprites (Y = 00 cada 4 bytes). shadow_cursor = 00.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; === FIXES
;;  Tipo: Cant. => Tramos
;;  *  N:    __ => __     (1 fix = -1 tramo)
;;  *  E:    __ => __     (1 fix = -1 tramo)
;;  *  S:    __ => __     (2 fix = -1 tramo. En grupos de 2 solo)
;;  *  F:    __ => __     (2 fix = -1 tramo. En grupos de 2 solo)
;;      TOTAL:     __ tramos
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;;  *
