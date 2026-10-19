;;==============================================================
;; Challenge 5 · Ejercicio 10 · sys_collision_one: un solo impacto por pasada
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej10" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_collision_one` está en src/sys/sys_collision.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej10::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: la sonda golpea COMO MÁXIMO a una entidad por pasada. Si `collision_hits` ya no es 0, ignora la candidata.
;;   Usa `sys_collision_overlaps` con su contrato nuevo (`Z` = se solapan).
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 10", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks ONE entity (the candidate) against the probe, which is in
;; collision_probe. If the candidate has the COLLIDER component, its
;; KIND is one of the kinds in collision_mask, and it overlaps the probe,
;; then it is freed and collision_hits is incremented.
;; But the probe hits at most ONE entity per pass: if collision_hits is not 0
;; already, the candidate is ignored.
;; 📥 INPUT: DE: candidate entity
;; ❌ May modify A, DE, HL
;; ⚠️ Use sys_collision_overlaps and man_entity_free
ej10::   ;; = `sys_collision_one`, que está en src/sys/sys_collision.asm
    ;; ◉◉YOUR CODE◉◉

ld a, [de]
and CMP_COLLIDER
ret z



    ld   hl, E_KIND             ;; \ HL = &candidate.KIND
    add  hl, de                 ;; |
    ld   a, [collision_mask]    ;; | A = collision_mask & candidate.KIND:
    and  [hl]                   ;; | is it a kind the probe collides with?
    ret  z                      ;; / No: ignore it

    ld a, [collision_probe]
    ld l, a
    ld a, [collision_probe + 1]
    ld h, a
    push de
    call sys_collision_overlaps
    pop de
    ret nz

    ld a, [collision_hits]
    cp 0
    ret nz
    inc a
    ld [collision_hits], a
    jp man_entity_free


    ;; ◉◉YOUR CODE◉◉
    ; ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej10 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Sonda = la nave (entidad 0, Y=144, X=84). Máscara = KIND_ENEMY. collision_hits = 0. Candidata: asteroide en (Y=140, X=88), entidad 3.
;; [CPU]
;; [MEM] collision_probe (4 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  .. .. .. .. 00 C1 04 01|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array + 24 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C110  .. .. .. .. .. .. .. ..|00 8C 58 4D 00 00 00 04|
;;  collision_probe, collision_mask y collision_hits van seguidos.
;;  collision_hits = 01 y la candidata queda libre (CMP = 00).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Igual, pero collision_hits ya vale 01: la sonda ya ha golpeado a otra entidad en esta pasada.
;; [CPU]
;; [MEM] collision_probe (4 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  .. .. .. .. 00 C1 04 01|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array + 24 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C110  .. .. .. .. .. .. .. ..|87 8C 58 4D 00 00 00 04|
;;  Como máximo UN impacto por pasada: la candidata se ignora (sigue viva) y collision_hits sigue en 01.
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
