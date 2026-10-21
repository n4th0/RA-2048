;;==============================================================
;; Challenge 6 · Ejercicio 02 · Implementa camera_axis
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej02" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `camera_axis` está en src/sys/sys_camera.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej02::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: `C` ya no es el máximo de la cámara. Es el tamaño de la pantalla en ese eje (160 en X, 144 en Y). El mundo mide siempre 256 píxeles, así que el máximo es `256 − C`.
;;
;;   La cámara es `posición − offset`, sin bajar de 0 y sin pasar del máximo.
;;   1. `A` = posición de la entidad en ese eje, `B` = offset (dónde queda la entidad en la pantalla), `C` = tamaño de la pantalla.
;;   2. Calcula `A − B`. Si el resultado baja de 0 (acarreo), devuelve 0.
;;   3. Si el resultado es menor que `256 − C`, devuélvelo. Si no, devuelve `256 − C`.
;;
;;   Modifica `A` y `B`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 02", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The camera for ONE axis: position - offset, not below 0 and not above the maximum.
;; The world is 256 pixels long: the maximum is 256 minus the screen size in that axis.
;; 📥 A = position of the entity in that axis, B = offset, C = screen size in that axis
;; ⫷▬ A = the camera in that axis
;; ❌ Modifies A, B
ej02::   ;; = `camera_axis`, que está en src/sys/sys_camera.asm
   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej02 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> camera_axis con A = 120, B = 72, C = 160 (el ancho de la pantalla).
;; [MEM] tst_log (1 byte)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C800  30 .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  120 − 72 = 48 (30 en hexadecimal). El máximo es 256 − 160 = 96 y 48 es menor: es la cámara.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> camera_axis con A = 30, con A = 250 (B = 72, C = 160) y con A = 250 (B = 64, C = 144, el alto de la pantalla).
;; [MEM] tst_log (3 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C800  00 60 70 .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  30 − 72 baja de 0 (acarreo): 0. 250 − 72 = 178 pasa del máximo 256 − 160 = 96 (60 en hexadecimal): 96. 250 − 64 = 186 pasa del máximo 256 − 144 = 112 (70): 112.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
