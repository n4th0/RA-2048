;;==============================================================
;; Challenge 6 · Ejercicio 03 · Implementa sys_render_scroll
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej03" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_render_scroll` está en src/sys/sys_render.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej03::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: `sys_camera_get` devuelve ahora `B` = cámara X y `C` = cámara Y.
;;
;;   Mueve el background a la posición de la cámara.
;;   1. Pide la cámara con `sys_camera_get`.
;;   2. Escribe la cámara X en `rSCX` y la cámara Y en `rSCY`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 03", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Moves the background to the position of the camera: the scroll. The registers
;; rSCX and rSCY say which pixel of the background is at the top left of the screen.
;; ⚠️ Changing them in the middle of a frame tears the picture: do it in VBLANK
;; (or with the screen off).
;; ❌ Modifies A, BC
ej03::   ;; = `sys_render_scroll`, que está en src/sys/sys_render.asm
call sys_camera_get
ld a, b
ldh [rSCX], a
ld a, c
ldh [rSCY], a
ret
   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej03 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> cam_x = 48 y cam_y = 30. rSCY y rSCX valían FF.
;; [MEM] rSCY, rSCX (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FF40  .. .. 1E 30 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  rSCX = cam_x = 48 (30 en hexadecimal) y rSCY = cam_y = 30 (1E).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> cam_x = 96 y cam_y = 112 (la esquina de abajo a la derecha). rSCY y rSCX valían FF.
;; [MEM] rSCY, rSCX (2 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FF40  .. .. 70 60 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  rSCX = 96 (60 en hexadecimal) y rSCY = 112 (70).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
