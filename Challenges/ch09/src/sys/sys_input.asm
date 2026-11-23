;;==============================================================
;; Challenge 5 · Sistema de entrada (componente INPUT)
;; Pone el VX de las entidades con INPUT según la cruceta, y nada más: no mueve
;; la entidad (lo hace sys_physics) ni dispara (es una regla del juego).
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: input", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input system, for ONE entity: sets its VX from the D-pad, and nothing else:
;;   LEFT -> -INPUT_SPEED, RIGHT -> +INPUT_SPEED, none (or both) -> 0.
;; It works with ANY entity that has INPUT (today, only the ship). It does not move
;; the entity or limit where it goes: sys_physics does both, as with any other.
;; Only works on entities with the INPUT component: when the ship loses it,
;; it stops obeying the player.
;; 📥 DE = entity
;; ❌ Modifies A, BC, HL
sys_input_one::
   INCBIN "bin/sys_input_one.bin"         ;; Rutina dada, en binario (30 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input system, for ALL the entities that have INPUT.
;; ❌ Modifies A, BC, DE, HL
sys_input_update::
   INCBIN "bin/sys_input_update.bin"      ;; Rutina dada, en binario (6 bytes)
