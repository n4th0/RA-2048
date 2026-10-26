;;==============================================================
;; Challenge 6 · Ejercicio 09 · Implementa world_to_oam
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej09" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `world_to_oam` está en src/sys/sys_prerender.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej09::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: `sys_camera_get` devuelve ahora `B` = cámara X y `C` = cámara Y. El resultado sigue siendo `B` = Y de la OAM y `C` = X de la OAM.
;;
;;   Las entidades guardan su posición en el mundo. Para dibujarlas hay que pasarla a coordenadas de la OAM: restar la cámara y sumar el offset de la OAM.
;;
;;   📥 `D` = Y del mundo, `E` = X del mundo.
;;   - `B` = `D` − cámara Y + `OAM_Y_OFFSET`
;;   - `C` = `E` − cámara X + `OAM_X_OFFSET`
;;
;;   Todo en 8 bits. No modifica `DE` ni `HL`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 09", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Changes a position from WORLD coordinates to OAM coordinates:
;;    OAM = world - camera + offset   (offset: OAM_Y_OFFSET for Y, OAM_X_OFFSET for X)
;; The screen position is the world position minus the camera, and the OAM adds 16 to Y
;; and 8 to X (a sprite can be partly off the screen). All in 8 bits: if it is
;; outside the screen, the result wraps around to values that the console does not draw
;; (Y >= 160 or X >= 168).
;; 📥 D = world Y, E = world X
;; ⫷▬ B = OAM Y, C = OAM X
;; ❌ Modifies A, BC. Does NOT modify DE or HL
;; ⚠️ Use sys_camera_get: it gives B = camera X and C = camera Y
ej09::   ;; = `world_to_oam`, que está en src/sys/sys_prerender.asm
   call sys_camera_get
   ld a, d
   sub c
   add OAM_Y_OFFSET
   push af ;; FIX N1: Usado push solo con a por error en vez de con af 

   ld a, e
   sub b 
   add OAM_X_OFFSET ;; FIX S1: Puesto OAM_Y_OFFSET por error
   ld c, a
   pop af ;; N1 otra vez con el pop
   ld b, a
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej09 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Cámara X = 50, Y = 20. D = 60 (Y), E = 100 (X). HL = 1234.
;; [CPU]
;;    bc = 383A
;;    de = 3C64
;;    hl = 1234
;;  B = 60 − 20 + 16 = 56 (38 en hexadecimal) y C = 100 − 50 + 8 = 58 (3A). DE y HL no cambian.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Cámara X = 50, Y = 20. D = 2 (Y), E = 3 (X). HL = 1234.
;; [CPU]
;;    bc = FED9
;;    de = 0203
;;    hl = 1234
;;  B = 2 − 20 + 16 = −2, que en 8 bits es 254 (FE), y C = 3 − 50 + 8 = −39, que es 217 (D9). DE y HL no cambian.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; ==========================================================
;; === FIXES
;;  Tipo: Cant.
;;  *  N:    1     (no existe)
;;  *  E:    __     (errónea)
;;  *  S:    1     (sintaxis)
;;  *  F:    __     (falta algo)
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;;  *
;; 
