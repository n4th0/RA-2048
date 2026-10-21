;;==============================================================
;; Challenge 6 · Sistema de física (componente PHYSICS)
;; Mueve las entidades con su velocidad. El mapa las detiene: no entran en las
;; tiles sólidos. También guarda hacia dónde mira y camina cada entidad.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: physics", ROM0

;; The velocity (VY, VX) of walking in each direction. The index is the direction
;; (DIR_DOWN, DIR_UP, DIR_LEFT, DIR_RIGHT): each entry is 2 bytes
DirVelocity:
   DB  WALK_SPEED, 0            ;; DIR_DOWN
   DB -WALK_SPEED, 0            ;; DIR_UP
   DB 0, -WALK_SPEED            ;; DIR_LEFT
   DB 0,  WALK_SPEED            ;; DIR_RIGHT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Makes an entity walk in a direction: it faces that way, and its velocity is the one
;; of the table. The systems that decide (input, ai) call this: the velocity and the
;; direction are written only by the physics.
;; 📥 DE = entity, B = direction (DIR_DOWN, DIR_UP, DIR_LEFT, DIR_RIGHT)
;; ❌ Modifies A, BC, HL
sys_physics_walk::
   INCBIN "bin/sys_physics_walk.bin"      ;; Rutina dada, en binario (27 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Makes an entity stand still (the direction it faces does not change).
;; 📥 DE = entity
;; ❌ Modifies A, HL
sys_physics_stop::
   INCBIN "bin/sys_physics_stop.bin"      ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Is the entity's FEET box inside a solid tile? It is enough to check its 4 corners:
;; the box is as big as a tile (8 x 8), so a tile it touches always has a corner inside.
;; 📥 DE = entity
;; ⫷▬ NZ, a corner is in a solid tile: the entity cannot be here
;;    Z,  all 4 corners are free
;; ❌ Modifies A, BC, HL
sys_physics_blocked::
   INCBIN "bin/sys_physics_blocked.bin"   ;; Rutina dada, en binario (49 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Moves ONE entity: X += VX, then Y += VY. Each axis on its own: if the entity ends up
;; with its feet in a solid tile, that move is undone, and it can still slide along the
;; wall with the other axis.
;; ⚠️ Precondition: the entity has CMP_PHYSICS.
;; 📥 DE = entity
;; ❌ Modifies A, BC, HL
sys_physics_one::
   INCBIN "bin/sys_physics_one.bin"       ;; Rutina dada, en binario (57 bytes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Moves ALL the entities that have PHYSICS.
;; ❌ Modifies A, BC, DE, HL
sys_physics_update::
   INCBIN "bin/sys_physics_update.bin"    ;; Rutina dada, en binario (8 bytes)
