;;==============================================================
;; Challenge 5 · Ejercicio 09 · sys_collision_overlaps: resultado en Z y una distancia por eje
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej09" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_collision_overlaps` está en src/sys/sys_collision.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej09::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: el resultado va en `Z` (`Z` = se solapan, `NZ` = no). Cada eje tiene su distancia: `|Y1 - Y2| < HIT_H` y `|X1 - X2| < HIT_W`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 09", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Do two entities overlap? They do if the distance between their positions
;; is less than HIT_H in Y AND less than HIT_W in X:
;; |Y1 - Y2| < HIT_H and |X1 - X2| < HIT_W.
;; 📥 INPUT:   DE: entity 1,  HL: entity 2
;; ⫷▬ RETURNS (in the Z flag):
;;    Z,  they overlap
;;    NZ, they do not
;; ❌ May modify A, DE, HL
ej09::   ;; = `sys_collision_overlaps`, que está en src/sys/sys_collision.asm
    inc  de                     ;; \ DE -> Y1
    inc  hl                     ;; / HL -> Y2

    ld   a, [de]                ;; \ A = Y1 - Y2
    sub  [hl]                   ;; /

    jr   nc, .y_positive        ;; \ Positive: it is already |dY|
    cpl                         ;; | Negative: |dY| = -dY
    inc  a                      ;; / (cpl + inc: two's complement)

.y_positive

    cp HIT_H
    jr nc, .no_overlap
    inc de
    inc hl 
    ld a, [de]
    sub [hl]
    jr nc, .x_positive
    cpl 
    inc a
  .x_positive:
    cp HIT_W
    jr nc, .no_overlap
    xor a
    ret
  .no_overlap:
    or 1
    ret


;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej09 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 1 en (Y=50, X=50) y entidad 2 en (Y=53, X=56). DE = entidad 1, HL = entidad 2. HIT_H = 5, HIT_W = 7.
;; [CPU]
;;    flag Z: 1   ← Z = se solapan · NZ = no
;;  |dY| = 3 < 5 y |dX| = 6 < 7: se solapan.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 1 en (Y=50, X=50) y entidad 2 en (Y=50, X=57). DE = entidad 1, HL = entidad 2.
;; [CPU]
;;    flag Z: 0   ← Z = se solapan · NZ = no
;;  |dY| = 0 pero |dX| = 7: no es menor que HIT_W (7). No se solapan.
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
