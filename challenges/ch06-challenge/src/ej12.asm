;;==============================================================
;; Challenge 6 · Ejercicio 12 · sys_animation_image: Encuentra y corrige los errores
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. El código con errores YA ESTÁ aquí abajo, igual que en el papel: no lo copies. Corrígelo aquí mismo.
;;     Este fichero se llama ej12.asm.no para que el proyecto compile mientras tanto. Cuando empieces,
;;     renómbralo a ej12.asm.
;;  2. Cada corrección, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej12" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_animation_image` está en src/sys/sys_animation.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej12::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: el paso cambia cada 4 frames: es el bit 2 de `TICK` (`ANIM_STEP_MASK = %00000100`). Ese bit ya vale 0 o 4 (`TILES_PER_IMAGE`).
;;
;;   Elige la imagen que muestra una entidad. `DE` = entidad, que tiene `ANIMATION`.
;;   - Su imagen es `TILE` = `SHEET` + la fila de su dirección (`DirImage`) + el paso. `ATTR` lleva el flip de su dirección, sin tocar el resto de sus bits.
;;   - El `TICK` ya lo ha decidido `sys_animation_one` (ejercicio 11): aquí solo se lee.
;;
;;   El código completo viene con errores de todo tipo. Encuéntralos y arréglalos.
;;
;; PISTAS
;;   - Cada entrada de `DirImage` ocupa 2 bytes. Mira cómo se calcula su índice.
;;   - `res` pone a 0 un bit, así luego `or` puede "añadirlo" porque `0 or X = X`.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 12", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The image of an entity: the image it shows is
;;      TILE = SHEET + the row of its direction + the image of its step
;; and ATTR gets the flip of its direction. The step changes every 4 frames, so it
;; alternates between its 2 images.
;; 📥 DE = entity
;; ❌ Modifies A, BC, HL
ej12::   ;; = `sys_animation_image`, que está en src/sys/sys_animation.asm
   ld   h, d                    ;; \ A = TICK
   ld   a, e                    ;; | (HL = &entity.TICK)
   add  E_TICK                  ;; |
   ld l, a
   ld   a, [hl]                 ;; /
   and  ANIM_STEP_MASK          ;; \ Bit 2 of TICK: 0 for 4 frames, 4 for 4 frames...
   ;; FIX E1: Faltó eliminar la instrucción rrca que era errónea
   ld   b, a                    ;; / B = tile offset of its step: 0 or 4 (no shift)

   ld   h, d                    ;; \ A = entity.DIR
   ld   a, e                    ;; |
   add  E_DIR                   ;; |
   ld   l, a                    ;; |
   ld   a, [hl]                 ;; /
   add a
   ld   c, a                    ;; \ BC = DIR * 2: the offset in the table
   ld   a, b                    ;; | A = the offset of the step
   ld   b, 0                    ;; /
   ld   hl, DirImage           ;; \ HL = &DirImage[DIR]
   add  hl, bc                  ;; /

   add  [hl]                    ;; \ A = step offset + tile of the row of its direction
   inc  hl                      ;; | (HL -> the flip)
   ld   b, [hl]                 ;; / B = the flip of its direction
   ld   c, a                    ;; C = that tile (A is needed to build the addresses)

   ld   h, d                    ;; \ HL = &entity.SHEET
   ld   a, e                    ;; |
   add  E_SHEET                 ;; |
   ld   l, a                    ;; /
   ld   a, c                    ;; \ C = the tile of the image:
   add  [hl]                    ;; | that tile + entity.SHEET
   ld   c, a                    ;; /

   ld   h, d                    ;; \ HL = &entity.TILE
   ld   a, e                    ;; |
   add  E_TILE                  ;; |
   ld   l, a                    ;; /
   ld   [hl], c                 ;; \ entity.TILE = C
   inc  l                       ;; / (HL -> ATTR: the next field)

   ld   a, [hl]                 ;; \ entity.ATTR = its ATTR with the flip of
   res  ATTR_XFLIP_BIT, a       ;; | its direction (the other bits stay)
   or   b                       ;; |
   ld   [hl], a                 ;; /

   ret

;; ==========================================================
;;  ENSAMBLA: SÍ  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej12 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 0: DIR_LEFT, TICK = 7, SHEET = 80, ATTR = 0. DE = entidad 0. (TICK no cambia aquí.)
;; [CPU]
;;    de = C000
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  A3 00 00 64 20 00 FF 00|02 50 07 00 00 00 00 00|
;;  El bit 2 de 7 vale 1: el paso es 4. DIR_LEFT: fila 16 y flip horizontal. TILE = 80 + 16 + 4 = 100 (64 en hexadecimal) y ATTR = 20.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: OK  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Entidad 0: DIR_UP, TICK = 13, SHEET = 80, ATTR = $30 (paleta 1 y flip horizontal). DE = entidad 0.
;; [CPU]
;;    de = C000
;; [MEM] entity_array (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C000  A3 00 00 5C 10 00 00 00|01 50 0D 00 00 00 00 00|
;;  El bit 2 de 13 vale 1: el paso es 4. DIR_UP: fila 8 y sin flip. TILE = 80 + 8 + 4 = 92 (5C). ATTR pasa de 30 a 10: la paleta se conserva y el flip se borra.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; === FIXES
;;  Tipo: Cant.
;;  *  N:    __     (no existe)
;;  *  E:    1     (errónea)
;;  *  S:    __     (sintaxis)
;;  *  F:    __     (falta algo)
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;;  *

