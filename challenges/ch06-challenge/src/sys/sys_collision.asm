;;==============================================================
;; Challenge 6 · Sistema de colisiones (componente COLLIDER)
;; Una sonda contra todas las entidades, filtrando por KIND. El sistema no sabe qué
;; choca con qué ni qué causa cada colisión: eso son reglas del juego (game_handle_collisions).
;; Solo dice CON QUIÉN ha chocado la sonda; no destruye nada.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Collision data", WRAM0
collision_probe: DS 1                 ;; entity that is being tested against the rest (its low byte)
collision_mask:  DS 1                 ;; kinds the probe collides with
collision_hit:   DS 1                 ;; the first entity the probe has collided with (low byte, ENTITY_NONE = none)

SECTION "System: collision", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Do two entities overlap? They do if, in BOTH axes, the distance between their
;; positions is less than the size of the hit: |Y1 - Y2| < HIT_H and |X1 - X2| < HIT_W.
;; 📥 INPUT:   DE: entity 1,  HL: entity 2
;; ⫷▬ RETURNS:
;;    C,  they overlap
;;    NC, they do not
;; ❌ May modify A, DE, HL
sys_collision_overlaps::
   INCBIN "bin/sys_collision_overlaps.bin" ;; Rutina dada, en binario (22 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks ONE entity (the candidate) against the probe, which is in
;; collision_probe. If its KIND is one of the kinds in collision_mask, and it
;; overlaps the probe, it is remembered in collision_hit. Only the FIRST one: the
;; rest are ignored.
;; ⚠️ Precondition: the candidate has CMP_COLLIDER.
;; 📥 INPUT: DE: candidate entity
;; ❌ May modify A, DE, HL
sys_collision_one::
   INCBIN "bin/sys_collision_one.bin"     ;; Rutina dada, en binario (33 bytes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks ONE probe against ALL the entities: it is the 'update' of this system.
;; Unlike the other systems, it needs context (the probe and the kinds it collides
;; with): that is why it has parameters. The game calls it once per probe.
;; The probe must have the COLLIDER component too: an entity that has lost
;; it collides with nothing.
;; 📥 INPUT:   HL: the probe (entity), B: mask of the kinds it collides with
;; ⫷▬ RETURNS: NZ, it collided: DE = the first entity it collided with
;;             Z,  it did not (and DE is not valid)
;; ❌ May modify A, BC, DE, HL
sys_collision_update::
   INCBIN "bin/sys_collision_update.bin"  ;; Rutina dada, en binario (34 bytes)
