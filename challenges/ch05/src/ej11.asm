;;==============================================================
;; Challenge 5 · Ejercicio 11 · scene_menu_update / scene_gameover_update: START y A
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej11" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `scene_menu_update` está en src/scn/scn_menu.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej11a::`.
;;   `scene_gameover_update` está en src/scn/scn_gameover.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej11b::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: en el menú empieza la partida con START o A. En Game Over, START vuelve al menú y A juega otra vez (`scene_game`).
;;
;; PISTAS
;;   - `and BTN_START | BTN_A` mira los dos botones a la vez.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 11a", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu scene, every frame: if START or A has just been pressed, go to
;; the game scene (scene_game). If not, do nothing.
;; ⚠️ Use input_pressed (the "edge") and scene_change
ej11a::   ;; = `scene_menu_update`, que está en src/scn/scn_menu.asm

    ld a, [input_pressed]
    and BTN_START | BTN_A
    ret z
    ld hl, scene_game
    call scene_change
    ret
    ;; ◉◉YOUR CODE◉◉
    ret ;; ◀━REMOVE RET IF NEEDED

SECTION "Ejercicio 11b", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game over scene, every frame:
;;  - If START has just been pressed, go to the menu scene (scene_menu).
;;  - If A has just been pressed, play again: go to the game scene (scene_game).
;;  - If not, do nothing.
;; Each scene only updates its own things: this one does not touch the game.
;; ⚠️ Use input_pressed (the "edge") and scene_change
ej11b::   ;; = `scene_gameover_update`, que está en src/scn/scn_gameover.asm
    ;; ◉◉YOUR CODE◉◉

    ld a, [input_pressed]
    cp BTN_START
    jr z, .start
    cp BTN_A
    ret nz
    ld hl, scene_game
    call scene_change

    ret
.start

    ld hl, scene_menu
    call scene_change
    ret





;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej11 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Escena actual = menú. Se acaba de pulsar A (no START). Llamamos a la actualización del menú (ej11a).
;; [CPU]
;; [MEM] scene_current (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  .. .. .. .. .. .. .. ..|BA 0C .. .. .. .. .. ..|
;;  scene_current = dirección de scene_game (0CBA, byte bajo primero).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Escena actual = Game Over. Se acaba de pulsar A. Llamamos a la actualización de Game Over (ej11b).
;; [CPU]
;; [MEM] scene_current (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  .. .. .. .. .. .. .. ..|BA 0C .. .. .. .. .. ..|
;;  scene_current = dirección de scene_game (0CBA): se juega otra vez directamente.
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
