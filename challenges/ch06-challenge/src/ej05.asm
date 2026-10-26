;;==============================================================
;; Challenge 6 · Ejercicio 05 · Completa hud_draw_hearts
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej05" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `hud_show` está en src/engine/ui/hud.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej05a::`.
;;   `hud_draw_hearts` está en src/engine/ui/hud.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej05b::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: los corazones se llenan de derecha a izquierda.
;;
;;   `hud_show` no cambia: ya está hecha.
;;
;;   `hud_draw_hearts`: dibuja los corazones. `C` = corazones del héroe.
;;   1. Escribe `HEARTS_MAX` celdas seguidas, desde `HUD_HEARTS_CELL` (ya cargada en `HL`).
;;   2. Las últimas `C` llevan `TILE_HEART_FULL` y las demás, `TILE_HEART_EMPTY`. `C` va de 0 (todos vacíos) a `HEARTS_MAX` (todos llenos).
;;
;; PISTAS
;;   - `ld a, tile` no cambia los flags: puedes comparar y cargar el tile después.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 05a", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shows the window at the bottom of the screen.
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A
ej05a::   ;; = `hud_show`, que está en src/engine/ui/hud.asm
   ld   a, HUD_WINDOW_X         ;; \ The window starts at the left of the screen
   ldh  [rWX], a                ;; /
   ld   a, HUD_WINDOW_Y         ;; \ and at the last row of tiles
   ldh  [rWY], a                ;; /

   ret

SECTION "Ejercicio 05b", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draws the hearts of the HUD: HEARTS_MAX cells, the LAST C full (they fill from the
;; right) and the rest empty.
;; 📥 C = hearts the hero has
;; ❌ Modifies A, BC, HL
ej05b::   ;; = `hud_draw_hearts`, que está en src/engine/ui/hud.asm
   ld   b, HEARTS_MAX           ;; B = hearts to draw
   ld   hl, HUD_HEARTS_CELL     ;; HL = the first cell of the hearts


    ld a, l
    add b
    dec a ; FIX F1 FALTA
    ld l, a
.hearts:
    ld a, c
    cp 0 
    jr z, .empty
    ld a, TILE_HEART_FULL
    dec c 
    jr .draw
.empty:
    ld a, TILE_HEART_EMPTY
.draw:
    ld [hl], a
    dec hl
    dec b
    jr nz, .hearts

   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej05 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> rWY y rWX valían 0 y las 3 celdas de los corazones (HUD_HEARTS_CELL), EE. hud_show y después hud_draw_hearts con C = 2.
;; [MEM] rWY, rWX (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FF40  .. .. .. .. .. .. .. ..|.. .. 88 07 .. .. .. ..|
;; [MEM] HUD_HEARTS_CELL (3 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   9C00  .. 46 45 45 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  hud_show: rWY = HUD_WINDOW_Y = 136 (88 en hexadecimal) y rWX = HUD_WINDOW_X = 7. Con C = 2, los dos corazones llenos están a la derecha: vacío (TILE_HEART_EMPTY = 46), lleno (45), lleno (45).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Igual, pero hud_draw_hearts con C = 0.
;; [MEM] rWY, rWX (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FF40  .. .. .. .. .. .. .. ..|.. .. 88 07 .. .. .. ..|
;; [MEM] HUD_HEARTS_CELL (3 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   9C00  .. 46 46 46 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Con C = 0 no hay ningún corazón lleno: las 3 celdas vacías, 46, 46, 46.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
