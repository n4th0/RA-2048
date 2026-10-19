;;==============================================================
;; Challenge 5 · Ejercicio 04 · sys_shot_spawn: crear el disparo, con shot_entity de un byte
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej04" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_shot_spawn` está en src/sys/sys_shot.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej04::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: `shot_entity` ocupa UN byte: el byte bajo de la dirección del disparo. El byte alto siempre es `HIGH(entity_array)`: el array está alineado.
;;   Vale `SHOT_NONE` (`$FF`) si no hay disparo.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 04", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates THE shot at a position. There can only be ONE shot: if it already
;; exists, or there is no free entity, it does nothing.
;; The entity is created from ShotTemplate data, and then Y and X are changed.
;; The system stores the address of the entity in shot_entity (only its LOW byte)
;; Where the shot appears (D, E) = (Y, X) is a rule of the game: shot_spawn decides it.
;; 📥 INPUT:   D = Y, E = X
;; ⫷▬ RETURNS: Z, the shot has been created
;;             NZ, it has not (there was one, or there is no free entity)
;; ❌ May modify A, BC, HL. Does NOT modify DE
;; ⚠️ Use man_entity_create
ej04::   ;; = `sys_shot_spawn`, que está en src/sys/sys_shot.asm
    ld a, [shot_entity]
    cp SHOT_NONE
    jr z, .create
    or 1
    ret
.create:
    ld hl, ShotTemplate
    call man_entity_create
    ld a, l ;(F: faltaba esta linea)
    ld [shot_entity], a ;(previo N: ld shot_entity, l)
    inc hl
    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl], a
    cp a
    ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej04 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Solo la nave. shot_entity = FF (SHOT_NONE). D = 100 (Y), E = 50 (X).
;; [CPU]
;;    flag Z: 1   ← Z = disparo creado · NZ = no
;;    de = 6432
;; [MEM] shot_entity (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  08 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  97 90 54 4B 00 00 00 01|87 64 32 4C 00 FC 00 02|
;;  shot_entity guarda solo el byte bajo de la entidad 1 (08). La entidad 1 se crea con ShotTemplate (con PHYSICS y VY = FC, que trae la plantilla), Y = 100 (64) y X = 50 (32). Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> La entidad 1 es un disparo y shot_entity vale 08. D = 100, E = 50.
;; [CPU]
;;    flag Z: 0   ← Z = disparo creado · NZ = no
;;    de = 6432
;; [MEM] shot_entity (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  08 00 .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (24 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  97 90 54 4B 00 00 00 01|87 14 1E 4C 00 FC 00 02|
;;   C110  00 00 00 00 00 00 00 00|.. .. .. .. .. .. .. ..|
;;  No se crea otro: la entidad 2 sigue libre y el disparo no cambia. Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; === FIXES
;;  Tipo: Cant. => Tramos
;;  *  N:    1 => -1      (1 fix = -1 tramo)
;;  *  E:    __ => __     (1 fix = -1 tramo)
;;  *  S:    __ => __     (2 fix = -1 tramo. En grupos de 2 solo)
;;  *  F:    1 => 0     (2 fix = -1 tramo. En grupos de 2 solo)
;;      TOTAL:    -1 tramos
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;;  *
