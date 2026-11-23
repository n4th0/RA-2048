;;==============================================================
;; Challenge 5 · Sistema de física (componente PHYSICS)
;; Mueve las entidades con su velocidad. Las que salen de la pantalla se liberan,
;; salvo las controladas por el jugador (INPUT), que no pueden pasar de sus límites.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: physics", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The limits of an entity that is controlled by the player (INPUT): X stays
;; between INPUT_X_MIN and INPUT_X_MAX. (Ideally every entity would have its own
;; limits and its own policy, but that is too much for this level.)
;; 📥 INPUT: HL = &entity.X, B = the new X (it is already written in the entity)
;; ❌ Modifies A
sys_physics_limit_x::
   INCBIN "bin/sys_physics_limit_x.bin"   ;; Rutina dada, en binario (14 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 03: `sys_physics_one`
;; La implementas TÚ, en src/ej03.asm (etiqueta `ej03::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_physics_one` y no necesita saber dónde está tu código.
sys_physics_one::
   jp   go_ej03              ;; Salta al ejercicio 03 (ver main.asm)
   ds   47, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Moves ALL the entities that have PHYSICS.
;; ❌ May modify A, BC, DE, HL
sys_physics_update::
   INCBIN "bin/sys_physics_update.bin"    ;; Rutina dada, en binario (6 bytes)
