;;==============================================================
;; Challenge 5 · Ejercicio 05 · sys_shot_update: comprobar el disparo, con shot_entity de un byte
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej05" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_shot_update` está en src/sys/sys_shot.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej05::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: igual que el ejercicio 4: `shot_entity` ocupa UN byte, vale `SHOT_NONE` si no hay disparo y la dirección de su entidad es `HIGH(entity_array)` : `shot_entity`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 05", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks that THE shot is still there, and if not, forgets it (shot_entity = SHOT_NONE).
;; sys_physics moves the shot and frees it when it leaves the screen, like any
;; other entity: this system does not move anything. The shot is still there only if
;; its entity is alive AND it is still a shot (KIND_SHOT): its slot may have been
;; freed, or taken by another entity (an asteroid, for example).
;; If there is no shot, it does nothing.
;; ❌ May modify A, HL
ej05::   ;; = `sys_shot_update`, que está en src/sys/sys_shot.asm
    ld   a, [shot_entity]       ;; \ HL = HIGH(entity_array) : shot_entity
    ld   l, a                   ;; | = the shot
    ld   h, HIGH(entity_array)  ;; /

    cp   SHOT_NONE              ;; \ Is there a shot?
    ret  z                      ;; / No: nothing to do

    ld   a, [hl]
    bit  CMP_ALIVE_BIT, a
    jr   z, .forget

    ld   a, l
    add  a, E_KIND
    ld   l, a
    ld   a, [hl]
    cp   KIND_SHOT
    ret  z

.forget
    ld   a, SHOT_NONE           ;; FIX E2 (Tipo E - Errónea): Cambiado xor a (00) por ld a, SHOT_NONE (FF) para cumplir el CASO 2.
    ld   [shot_entity], a
    ret


    ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej05 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Disparo en la entidad 1: Y = 100, X = 60 (shot_entity = 08). Llamamos a sys_shot_update (ej05).
;; [CPU]
;; [MEM] shot_entity (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  08 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array + 8 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  .. .. .. .. .. .. .. ..|87 64 3C 4C 00 FC 00 02|
;;  La entidad 1 está viva y es un disparo: no cambia nada. Mover el disparo es cosa de la física. Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> shot_entity vale 08 (la entidad 1). Llamamos DOS veces a sys_shot_update (ej05): primero con la entidad 1 libre (CMP = 00) y después con un asteroide en su sitio. Tras cada llamada, shot_entity debe valer FF (SHOT_NONE).
;; [CPU]
;; [MEM] shot_entity (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  FF 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] tst_log (1 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C800  FF .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array + 8 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  .. .. .. .. .. .. .. ..|87 64 3C 4D 00 00 00 04|
;;  tst_log: shot_entity tras la primera llamada (FF). Tras la segunda también vale FF. El asteroide que ocupa la entidad 1 no se toca. Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
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
