;;==============================================================
;; Challenge 5 · Ejercicio 12 · game_handle_collisions: la pasada nueva
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. Copia tu código del papel TAL CUAL en cada `◉◉YOUR CODE◉◉`. El resto ya está escrito.
;;  2. Cada cambio posterior, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej12" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `game_handle_collisions` está en src/scn/scn_game_rules.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej12::`.
;;
;; QUÉ HAY QUE HACER
;;   A diferencia del entrenamiento: el disparo también se comprueba contra las monedas (`KIND_BONUS`). Si alcanza alguna, llama a `game_bonus_shot` (ya hecha).
;;   La pasada del disparo contra asteroides puede haberlo destruido ya: `sys_shot_get` da `Z` si no hay disparo.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Ejercicio 12", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All the collisions of the game, and what they cause. The system
;; (sys_collision_update) only checks ONE probe against all the entities:
;; the rules of the game say who is the probe, who it collides with and what happens.
;;  1. The shot (if there is one, sys_shot_get) against the asteroids (KIND_ENEMY).
;;     If it hits any, call game_enemy_hit.
;;  2. The shot (if there is still one: the previous pass may have destroyed it)
;;     against the bonus items (KIND_BONUS). If it hits any, call
;;     game_bonus_shot: the shot breaks the bonus item.
;;  3. The ship (SHIP_ENTITY) against the asteroids. If it hits any:
;;     call game_ship_destroyed. The ship becomes an explosion and the
;;     game goes on until the explosion disappears.
;;  4. The ship against the bonus items (KIND_BONUS).
;;     If it catches any, call game_bonus_taken.
;; ⚠️ Use sys_shot_get, sys_collision_update, game_enemy_hit and game_bonus_shot
;; ⚠️ sys_collision_update returns Z (none) / NZ (at least one)
;; ❌ May modify A, BC, DE, HL
ej12::   ;; = `game_handle_collisions`, que está en src/scn/scn_game_rules.asm

call sys_shot_get
jr z, .ship
ld b, KIND_ENEMY
call sys_collision_update
call nz, game_enemy_hit
call sys_shot_get
jr z, .ship
ld b, KIND_BONUS
call sys_collision_update
call nz, game_bonus_shot

    ;; ◉◉YOUR CODE◉◉

.ship
    ld   hl, SHIP_ENTITY        ;; \ HL = the ship (the probe)
    ld   b, KIND_ENEMY          ;; | B = it collides with asteroids
    call sys_collision_update   ;; | A = how many it has hit
    call nz, game_ship_destroyed ;; / Some: the ship becomes an explosion

    ld   hl, SHIP_ENTITY        ;; \ HL = the ship (the probe)
    ld   b, KIND_BONUS          ;; | B = it collides with bonus items
    call sys_collision_update   ;; | A = how many it has caught
    call nz, game_bonus_taken   ;; / Some: points

    ret

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej12 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> La nave, un disparo (Y=60, X=100) y una moneda encima (Y=62, X=100).
;; [CPU]
;; [MEM] score (3 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  00 00 00 .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] shot_entity (1 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  FF .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (24 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  97 90 54 4B 00 00 00 01|00 3C 64 4C 00 FC 00 02|
;;   C110  00 3E 64 4F 00 00 00 08|.. .. .. .. .. .. .. ..|
;;  La moneda y el disparo desaparecen sin puntos (marcador 000, shot_entity = FF).
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> La nave, un disparo (Y=60, X=100), un asteroide encima (Y=62, X=100) y una moneda en el mismo sitio (entidad 3).
;; [CPU]
;; [MEM] score (3 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0A0  00 00 01 .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] shot_entity (1 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C0B0  FF .. .. .. .. .. .. ..|.. .. .. .. .. .. .. ..|
;; [MEM] entity_array (32 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   C100  97 90 54 4B 00 00 00 01|00 3C 64 4C 00 FC 00 02|
;;   C110  89 3C 64 50 00 00 00 0C|87 3E 64 4F 00 00 00 08|
;;  El disparo rompe el asteroide: 1 punto (marcador 001) y aparece una explosión en su sitio (entidad 2, CMP = 89). Ya no hay disparo (shot_entity = FF): la moneda NO se toca y sigue viva (CMP = 87).
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
