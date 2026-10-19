;;==============================================================
;; Challenge 5 · Ejercicio 01 · man_entity_alloc: reservar una entidad (corregir)
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. El código con errores YA ESTÁ aquí abajo, igual que en el papel: no lo copies. Corrígelo aquí mismo.
;;     Mientras tenga errores de tipo N o S no ensambla. Para probar otro ejercicio antes, renombra este fichero a ej01.asm.no
;;  2. Cada corrección, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej01" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `man_entity_alloc` está en src/man/man_entity.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej01::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: `man_entity_alloc` NO modifica `B` ni `DE`. No usa contador: termina comparando `L` con el final del array.
;;   El código tiene errores de todo tipo. Encuéntralos y corrígelos.
;;
;; PISTAS
;;   - `LOW(entity_array) + ENTITY_ARRAY_SIZE` es el valor de `L` justo después de la última entidad.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 01", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Looks for a free entity and reserves it.
;; 📥 INPUT:   A: components the new entity will have (CMP_SPRITE, ...)
;; ⫷▬ RETURNS: Z,  HL = address of the entity, and [HL] = A | CMP_ALIVE
;;             NZ, there is no free entity
;; ❌ May modify A, C, HL. Must NOT modify B or DE
;; ⚠️ It does not change the other fields: the caller fills them in
ej01::   ;; = `man_entity_alloc`, que está en src/man/man_entity.asm
    ld   c, a
    ld   hl, entity_array
.next
    bit  CMP_ALIVE_BIT, [hl]
    jr   z, .found
    ld   a, l
    add  a, SIZEOF_ENTITY ;(previo N: add SIZEOF_ENTITY)
    ld   l, a
    cp   LOW(entity_array) + ENTITY_ARRAY_SIZE
    jr   nz, .next
    or  1
    ret
.found
    ld   a, c
    OR CMP_ALIVE_BIT
    ld   [hl], a
    xor  a
    ret

;; ==========================================================
;;  ENSAMBLA: SÍ (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej01 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidades 0 y 1 vivas, la 2 libre. A = SPRITE | PHYSICS, B = 5A y DE = 1234 (no deben cambiar).
;; [CPU]
;;    flag Z: 1   ← Z = hay hueco · NZ = lleno
;;    hl = C110
;;    b  = 5A
;;    de = 1234
;; [MEM] entity_array (24 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  97 90 54 4B 00 00 00 01|87 28 3C 4D 00 00 00 04|
;;   C110  83 00 00 00 00 00 00 00|.. .. .. .. .. .. .. ..|
;;  La entidad 2 queda reservada: CMP = A | ALIVE = 83.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Las 8 entidades están vivas. A = SPRITE, B = 5A y DE = 1234.
;; [CPU]
;;    flag Z: 0   ← Z = hay hueco · NZ = lleno
;;    b  = 5A
;;    de = 1234
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  80 00 00 00 00 00 00 00|80 00 00 00 00 00 00 00|
;;  Ninguna entidad cambia. B y DE conservan su valor (no se usa contador).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; === FIXES
;;  Tipo: Cant. => Tramos
;;  *  N:    1 => -1     (1 fix = -1 tramo)
;;  *  E:    __ => __     (1 fix = -1 tramo)
;;  *  S:    __ => __     (2 fix = -1 tramo. En grupos de 2 solo)
;;  *  F:    __ => __     (2 fix = -1 tramo. En grupos de 2 solo)
;;      TOTAL:     -1 tramos
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;;  *
