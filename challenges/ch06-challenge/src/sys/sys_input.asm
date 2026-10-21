;;==============================================================
;; Challenge 6 · Sistema de entrada (componente INPUT)
;; Hace caminar a las entidades con INPUT según la cruceta, y nada más: no las
;; mueve (lo hace sys_physics) ni ataca (es una regla del juego).
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: input", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input system, for ONE entity: walks in the direction of the D-pad, and stops if
;; none is pressed. It walks in ONE direction at a time: if several buttons are pressed,
;; the first one of DOWN, UP, LEFT, RIGHT wins.
;; It works with ANY entity that has INPUT (today, only the hero). It does not move the
;; entity or check the map: sys_physics does both, as with any other.
;; ⚠️ Precondition: the entity has CMP_INPUT.
;; 📥 DE = entity
;; ❌ Modifies A, BC, HL
sys_input_one::
   INCBIN "bin/sys_input_one.bin"         ;; Rutina dada, en binario (34 bytes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input system, for ALL the entities that have INPUT.
;; ❌ Modifies A, BC, DE, HL
sys_input_update::
   INCBIN "bin/sys_input_update.bin"      ;; Rutina dada, en binario (8 bytes)
