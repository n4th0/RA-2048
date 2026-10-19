;;;==============================================================
;;; Challenge 5 · Ejercicio 03 · sys_physics_one: rebote (corregir)
;;;==============================================================
;;;
;;; CÓMO TRABAJAR
;;;  1. El código con errores YA ESTÁ aquí abajo, igual que en el papel: no lo copies. Corrígelo aquí mismo.
;;;     Mientras tenga errores de tipo N o S no ensambla. Para probar otro ejercicio antes, renombra este fichero a ej03.asm.no
;;;  2. Cada corrección, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej03" y make. BGB para en cada `ld b, b` (P1, P2).
;;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;;  4. Rellena el resumen del final.
;;;
;;; DÓNDE ESTÁ
;;;   `sys_physics_one` está en src/sys/sys_physics.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej03::`.
;;;
;;; QUÉ HAY QUE HACER
;;;   A diferencia del entrenamiento: una entidad sin `INPUT` que toca un lateral (`X >= ENTITY_OUT_X`; bajo 0 vale 255) REBOTA: su `VX` cambia de signo y no se libera. Por abajo (`Y >= ENTITY_OUT_Y`) se libera como antes.
;;;   El código tiene errores de todo tipo. Encuéntralos y corrígelos.
;;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 03", ROM0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Moves ONE entity: Y += VY, X += VX. Then, what happens at the edges depends on it:
;;;  - The entities with INPUT (the ship) are controlled by the player: they
;;;    cannot leave. Their limits are done by sys_physics_limit_x (given): jump to it.
;;;  - The others are freed if they leave through the bottom (Y >= ENTITY_OUT_Y).
;;;    If they touch a side (X >= ENTITY_OUT_X, note: below 0 wraps to 255),
;;;    they BOUNCE: their VX changes sign, and they come back next frame.
;;; Only works on entities with the PHYSICS component.
;;; (A semi-generic system: ideally every entity would have its own limits
;;;  and its own policy, but that is too much for this level.)
;;; 📥 INPUT: DE: entity
;;; ❌ May modify A, BC, DE, HL
ej03::   ;; = `sys_physics_one`, que está en src/sys/sys_physics.asm
    ld   a, [de]
    and  CMP_PHYSICS
    ret  z
    ld   hl, E_VY
    add  hl, de
    ld   a, [hl+]
    ld   c, a
    ld   a, [hl]
    ld   b, a
    ld   hl, E_Y
    add  hl, de
    ld   a, [hl]
    add  c
    ld   [hl+], a
    ld   c, a
    ld   a, [hl]
    add  b
    ld   [hl], a
    ld   b, a
    ld   a, [de]
    and  CMP_INPUT
    jp   nz, sys_physics_limit_x
    ld   a, c
    cp   ENTITY_OUT_Y
    jr   nc, .leaves
    ld   a, b
    cp   ENTITY_OUT_X
    ret  c
    ld   hl, E_VX
    add  hl, de
    ld   a, [hl]
    cpl
    inc a
    ld   [hl], a
    ret
.leaves
    jp   man_entity_free

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej03 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 1: asteroide en Y=50, X=80, VY=2, VX=-1 (FF). DE = entidad 1.
;; [CPU]
;; [MEM] entity_array + 8 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  .. .. .. .. .. .. .. ..|87 34 4F 4D 00 02 FF 04|
;;  Y = 50 + 2 = 52 (34 hex) y X = 80 - 1 = 79 (4F). Sigue viva y VX no cambia.
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 1: asteroide en Y=50, X=0, VY=1, VX=-1 (FF). DE = entidad 1.
;; [CPU]
;; [MEM] entity_array + 8 (8 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  .. .. .. .. .. .. .. ..|87 33 FF 4D 00 01 01 04|
;;  X pasa de 0 a FF (255): toca un lateral. No se libera: VX = -(-1) = +1 (01). Y = 51 (33 hex).
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
