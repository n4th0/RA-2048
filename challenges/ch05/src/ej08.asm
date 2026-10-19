;;==============================================================
;; Challenge 5 · Ejercicio 08 · sys_render_update: copiar a los sprites 8-15
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej08" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_render_update` está en src/sys/sys_render.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej08::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: los sprites de las entidades se copian a la OAM empezando en el sprite 8 (`ENTITIES_OAM`), no en el 0: los sprites 0-7 son del botón Start. Lo que se copia es lo mismo de siempre: el principio de `shadow_oam` (`SHADOW_OAM_SIZE` bytes).
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 08", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shows the sprites: waits for VBLANK and copies the sprites of the entities from the
;; shadow OAM to the OAM. The OAM can only be written during VBLANK (and with the screen off).
;;  - Source: the start of shadow_oam.   - Size: SHADOW_OAM_SIZE (8 sprites, 32 bytes).
;;  - Destination: the OAM at ENTITIES_OAM, the sprite 8 (the sprites 0-7 are for the Start button).
;; This routine knows nothing about entities: it is a plain copy.
;; ❌ May modify A, B, DE, HL
;; ⚠️ Use wait_vblank and memcpy8
ej08::   ;; = `sys_render_update`, que está en src/sys/sys_render.asm

    call wait_vblank
    ld hl, shadow_oam
    ld de, ENTITIES_OAM ; entitiees_oam <> lo que había antes
    ld b, SHADOW_OAM_SIZE; fix s shadow_oam_size <> lo que había antes
    ; call sys_prerender_update ; fix 
    jp memcpy8



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
;; [PREVIO]> La OAM sombra tiene 00, 01, 02 ... 9F (160 bytes).
;; [CPU]
;; [MEM] FE20 (32 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FE20  00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FE30  10 11 12 13 14 15 16 17|18 19 1A 1B 1C 1D 1E 1F|
;;  Los 32 bytes se copian a la OAM a partir del sprite 8 (FE20), no del 0.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> La OAM sombra tiene 80, 81 ... (160 bytes). Antes, la OAM FE00-FE5F se llena con 77.
;; [CPU]
;; [MEM] FE00 (96 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FE00  77 77 77 77 77 77 77 77|77 77 77 77 77 77 77 77|
;;   FE10  77 77 77 77 77 77 77 77|77 77 77 77 77 77 77 77|
;;   FE20  80 81 82 83 84 85 86 87|88 89 8A 8B 8C 8D 8E 8F|
;;   FE30  90 91 92 93 94 95 96 97|98 99 9A 9B 9C 9D 9E 9F|
;;   FE40  77 77 77 77 77 77 77 77|77 77 77 77 77 77 77 77|
;;   FE50  77 77 77 77 77 77 77 77|77 77 77 77 77 77 77 77|
;;  FE20-FE3F: 80 ... 9F (copiados). Todo lo demás (FE00-FE1F y FE40-FE5F) sigue en 77.
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
