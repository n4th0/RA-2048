;;==============================================================
;; Challenge 5 · Sistema de autodestrucción (componente SELFDESTROY)
;; Un ejemplo resuelto de cómo se añade un componente.
;;==============================================================
INCLUDE "man/man_entity.inc"

SECTION "System: selfdestroy", ROM0

;; A new component, as an example of how it is done: SELFDESTROY.
;; An entity with SELFDESTROY removes itself after some frames.
;;   - Data: the number of frames left. It lives in the KIND byte,
;;     which an entity with SELFDESTROY does not use (it has no COLLIDER).
;;   - System: sys_selfdestroy_one counts down ONE entity, and
;;     sys_selfdestroy_update does it with all of them (for_each).
;; An explosion is an entity with SPRITE + SELFDESTROY. It has no COLLIDER
;; (nothing collides with it) and no PHYSICS (it does not move).
;; Creating it is a rule of the game: explosion_spawn is in scn/scn_game_rules.asm.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counts down ONE entity. When it reaches 0, it is removed.
;; Only works on entities with the SELFDESTROY component.
;; 📥 DE = entity
;; ❌ Modifies A, HL
sys_selfdestroy_one::
   INCBIN "bin/sys_selfdestroy_one.bin"   ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counts down ALL the entities that have SELFDESTROY.
;; ❌ Modifies A, BC, DE, HL
sys_selfdestroy_update::
   INCBIN "bin/sys_selfdestroy_update.bin" ;; Rutina dada, en binario (6 bytes)
