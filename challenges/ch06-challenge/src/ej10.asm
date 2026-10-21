;;==============================================================
;; Challenge 6 · Ejercicio 10 · Completa sys_prerender_one
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Prueba: en main.asm, DEF TEST EQUS "test_ej10" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  3. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `sys_prerender_one` está en src/sys/sys_prerender.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej10::`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la Shadow OAM se llena de atrás hacia delante. `shadow_cursor` apunta al sitio de ESTA entidad (el sprite 0 va ahí y el sprite 1, a continuación) y, al acabar, tiene que apuntar al sitio de la siguiente, que queda antes que esta.
;;
;;   Prepara una entidad para dibujarla. Su imagen mide 16 × 16: se dibuja con 2 sprites de 8 × 16, uno al lado del otro, en la `shadow_oam`, a partir de `shadow_cursor`.
;;
;;   📥 `DE` = entidad.
;;
;;   El código dado calcula la posición en la OAM (`B` = Y, `C` = X de la mitad izquierda), descarta las entidades que invaden el HUD, carga `D` = `TILE`, `E` = `ATTR` y `HL` = dónde escribir, escribe el sprite 0 (la mitad izquierda) y, del sprite 1, su `Y`, su `TILE` y su `ATTR`. Si la entidad tiene flip (bit `ATTR_XFLIP` de `ATTR`), las dos mitades intercambian sus `X`: el sprite 0 va a la derecha y el sprite 1, a la izquierda. Tú escribes:
;;   1. La `X` del sprite 1, la mitad derecha: 8 píxeles más a la derecha que la del sprite 0 (`SPRITE_WIDTH`), salvo que haya flip.
;;   2. Guarda en `shadow_cursor` el sitio de la siguiente entidad: los 8 bytes anteriores a los de esta.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Ejercicio 10", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prepares ONE entity to be drawn. Its image is 16 x 16 pixels, drawn with 2
;; sprites of 8 x 16 (each one shows two tiles, one above the other):
;;      sprite 0: the left half, its tile is entity.TILE
;;      sprite 1: the right half, 8 pixels to the right, its tile is entity.TILE + 2
;; Its position in the OAM comes from its position in the world (world_to_oam).
;; Sprites are drawn OVER the window: an image that would reach the HUD (bottom below
;; HUD_WINDOW_Y) is not drawn at all. It appears when it is completely above the HUD.
;; If the image is mirrored (ATTR_XFLIP), each half is mirrored and they swap sides.
;; ⚠️ Precondition: the entity has CMP_SPRITE.
;; 📥 INPUT: DE: entity
;; ❌ May modify A, BC, DE, HL
ej10::   ;; = `sys_prerender_one`, que está en src/sys/sys_prerender.asm
   ld   h, d                    ;; \ HL = &entity.Y: the same page as the entity,
   ld   a, e                    ;; | the offset added to the low byte (no carry)
   add  E_Y                     ;; |
   ld   l, a                    ;; /

   ld   a, [hl+]                ;; \ D = entity.Y (HL -> X)
   ld   d, a                    ;; /
   ld   e, [hl]                 ;; E = entity.X
   call world_to_oam            ;; B = OAM Y, C = OAM X of the left half

   ld   a, b                    ;; \ Does its bottom (OAM Y) reach the HUD, or
   cp   HUD_WINDOW_Y + 1        ;; | is it below the screen (the Y wrapped around)?
   ret  nc                      ;; / Yes: not drawn

   inc  l                       ;; \ D = entity.TILE (HL -> TILE; DE is free now)
   ld   d, [hl]                 ;; /
   inc  l                       ;; \ E = entity.ATTR
   ld   e, [hl]                 ;; /

   ld   h, HIGH(shadow_oam)     ;; \ HL = where to write: the shadow OAM + the cursor
   ld   a, [shadow_cursor]      ;; |
   ld   l, a                    ;; /

   ld   a, b                    ;; \ Sprite 0: the left half
   ld   [hl+], a                ;; | Y
   ld   a, c                    ;; | X: normally on the left; mirrored, on the right
   bit  ATTR_XFLIP_BIT, e       ;; |
   jr   z, .left                ;; |
   add  SPRITE_WIDTH            ;; |
.left
   ld   [hl+], a                ;; |
   ld   a, d                    ;; | TILE
   ld   [hl+], a                ;; |
   ld   a, e                    ;; | ATTR
   ld   [hl+], a                ;; /

   ld   a, b                    ;; \ Sprite 1: the right half
   ld   [hl+], a                ;; | Y
   ;; ◉◉YOUR CODE◉◉
   ld   a, d                    ;; | TILE + TILES_PER_SPRITE (the right half)
   add  TILES_PER_SPRITE        ;; |
   ld   [hl+], a                ;; |
   ld   a, e                    ;; | ATTR
   ld   [hl+], a                ;; /

   ;; ◉◉YOUR CODE◉◉
   ret ;; ◀━REMOVE RET IF NEEDED

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej10 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Cámara X = 50, Y = 20. Entidad 0 en (Y = 60, X = 100), TILE = 80, ATTR = 0. shadow_cursor = 40. La Shadow OAM (96 bytes), llena de EE. DE = entidad 0.
;; [MEM] shadow_oam + 32 (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C120  EE EE EE EE EE EE EE EE|38 3A 50 00 38 42 52 00|
;; [MEM] shadow_cursor (1 byte)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0D0  .. .. .. 20 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Los sprites van a partir de shadow_oam + 40. Sprite 0 (la mitad izquierda): 38 3A 50 00. Sprite 1 (la derecha): 38 42 52 00. shadow_cursor retrocede 8: de 40 a 32 (20 en hexadecimal), donde irá la siguiente entidad.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> Igual, pero ATTR = $20 (flip horizontal) y shadow_cursor = 16.
;; [MEM] shadow_oam + 8 (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  .. .. .. .. .. .. .. ..|EE EE EE EE EE EE EE EE|
;;   C110  38 42 50 20 38 3A 52 20|.. .. .. .. .. .. .. ..|
;; [MEM] shadow_cursor (1 byte)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0D0  .. .. .. 08 .. .. .. ..|.. .. .. .. .. .. .. ..|
;;  Con el flip, las mitades intercambian la X. Sprite 0: 38 42 50 20. Sprite 1: 38 3A 52 20. Se escriben a partir de shadow_oam + 16. shadow_cursor pasa de 16 a 8.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
