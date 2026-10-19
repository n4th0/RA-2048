;;==============================================================
;; Challenge 5 · Ejercicio 06 · sys_prerender_one: preparar el sprite, con el cursor de un byte
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej06" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_prerender_one` está en src/sys/sys_prerender.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej06::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: `shadow_cursor` ocupa UN byte. `shadow_oam` está alineada a 256 (`LOW(shadow_oam) = 0`): la posición dentro de ella es solo el byte bajo.
;;
;; PISTAS
;;   - Destino: `HIGH(shadow_oam)` : `shadow_cursor`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 06", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prepares ONE entity to be drawn: copies its sprite (Y, X, TILE, ATTR:
;; 4 bytes, in the same order as the OAM) to the shadow OAM, to the place
;; that shadow_cursor says, and moves the cursor 4 bytes on.
;; If the entity does not have CMP_SPRITE, it does nothing.
;; 📥 INPUT: DE: entity
;; ❌ May modify A, B, DE, HL
;; ⚠️ Use memcpy8
ej06::   ;; = `sys_prerender_one`, que está en src/sys/sys_prerender.asm


    ld   a, [de]
    and  CMP_SPRITE ; fix s 
    ret  z

    ld   hl, E_SPRITE
    add  hl, de

    ld   a, [shadow_cursor]; fix e shadow_cursor <> shadow_oam 
    ld   e, a; fix e Esto monta DE = cursor·256 + 0. El byte bajo es el cursor y el alto es HIGH(shadow_oam): ld e, a y ld d, HIGH(shadow_oam).
    ld   d, HIGH(shadow_oam); 

    ld   b, 4                   
    call memcpy8                

    ld   a, e                   
    ld   [shadow_cursor], a; fix e shadow_cursor + 1 d <> [shadow_cursor] e
    ret


;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej06 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 0 (la nave, con SPRITE). shadow_cursor = 08 (un solo byte). La OAM sombra está llena de EE.
;; [CPU]
;; [MEM] shadow_oam (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  EE EE EE EE EE EE EE EE|90 54 4B 00 EE EE EE EE|
;; [MEM] shadow_cursor (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  .. 0C 00 .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Los 4 bytes de la nave se copian en shadow_oam + 8 y el cursor pasa a 0C. Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad con PHYSICS pero SIN SPRITE. shadow_cursor = 08. La OAM sombra, llena de EE.
;; [CPU]
;; [MEM] shadow_oam (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  EE EE EE EE EE EE EE EE|EE EE EE EE EE EE EE EE|
;; [MEM] shadow_cursor (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  .. 08 00 .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  No se copia nada y el cursor no se mueve. Se muestran 2 bytes para comprobar que solo escribes UNO: el segundo es el dato que va detrás y no debe cambiar (00).
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
