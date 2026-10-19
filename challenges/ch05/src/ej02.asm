;;==============================================================
;; Challenge 5 · Ejercicio 02 · man_entity_for_each: recorrer de la última a la primera
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej02" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `man_entity_for_each` está en src/man/man_entity.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej02::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: recorre de la ÚLTIMA entidad a la PRIMERA.
;;
;; PISTAS
;;   - Empieza en `entity_array + (MAX_ENTITIES - 1) * SIZEOF_ENTITY`.
;;   - Para retroceder, resta `SIZEOF_ENTITY` a `E`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 02", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calls a routine once for every entity that is alive, from the LAST one to the first.
;; 📥 INPUT: HL: address of the routine to call
;;           The routine receives DE = the entity, and it may modify
;;           every register: for_each looks after its own state.
;; ❌ May modify A, BC, DE, HL
;; ⚠️ Use "call call_hl" to call the routine whose address is in HL
ej02::   ;; = `man_entity_for_each`, que está en src/man/man_entity.asm

    ld de, entity_array + (MAX_ENTITIES-1)* SIZEOF_ENTITY
    ld b, MAX_ENTITIES
.next
    ld   a, [de]                ;; \ A = entity.CMP
    bit  CMP_ALIVE_BIT, a       ;; | Is it alive?
    jr   z, .skip               ;; / No (it is free): skip it

    push bc
    push de
    push hl

    call call_hl

    pop hl
    pop de
    pop bc

.skip                           ;; .skip is required by line 47
    ld a, e
    sub SIZEOF_ENTITY
    ld e, a
    dec b
    jr nz, .next
    ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej02 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidades 0, 2 y 5 vivas (solo CMP = 81). HL = tst_cb_log: apunta en tst_log el byte bajo de cada entidad y destruye todos los registros.
;; [CPU]
;; [MEM] tst_log (17 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C800  28 10 00 00 00 00 00 00|00 00 00 00 00 00 00 00|
;;   C810  03 .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  tst_log: byte bajo de cada entidad llamada, en orden. El último byte (C810) es tst_n: cuántas veces se llamó.
;;  Ahora se recorre de la última a la primera.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Las 8 entidades vivas. La rutina llamada destruye BC, DE y HL en cada llamada.
;; [CPU]
;; [MEM] tst_log (17 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C800  38 30 28 20 18 10 08 00|00 00 00 00 00 00 00 00|
;;   C810  08 .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Se llama 8 veces, de la última a la primera.
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
