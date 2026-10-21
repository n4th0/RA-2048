;;==============================================================
;; Challenge 6 · Sistema de la espada
;; Solo hay UNA espada en todo el juego: no usa for_each. Aquí está su estado
;; (sword_entity, que solo toca este fichero) y lo que hace cada frame: comprobar que
;; sigue ahí. La espada desaparece sola (SELFDESTROY). Sacar la espada (game_handle_attack)
;; es una regla del juego: está en scn/scn_game_rules.asm y usa sys_sword_spawn.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Sword data", WRAM0
sword_entity:    DS 1                 ;; THE sword: the low byte of its entity (ENTITY_NONE = there is none)

SECTION "System: sword", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the system: there is no sword.
;; ❌ Modifies A
sys_sword_init::
   INCBIN "bin/sys_sword_init.bin"        ;; Rutina dada, en binario (6 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ⫷▬ HL = address of the sword's entity, Z = there is no sword
;; ❌ Modifies A, HL
sys_sword_get::
   INCBIN "bin/sys_sword_get.bin"         ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates THE sword at a position. There can only be ONE sword: if it already
;; exists, or there is no free entity, it does nothing.
;; The entity is created from SwordTemplate data, and then Y and X are changed.
;; The system stores the entity (its low byte) in sword_entity.
;; Where the sword appears (D, E) = (Y, X), and which way it points, are rules of
;; the game: game_handle_attack decides them.
;; 📥 INPUT:   D = Y, E = X
;; ⫷▬ RETURNS: Z, the sword has been created: HL = its entity
;;             NZ, it has not (there was one, or there is no free entity)
;; ❌ May modify A, BC, HL. Does NOT modify DE
sys_sword_spawn::
   INCBIN "bin/sys_sword_spawn.bin"       ;; Rutina dada, en binario (26 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks that THE sword is still there, and if not, forgets it (sword_entity = 0).
;; SELFDESTROY removes the sword after some frames, like any other entity: this system
;; does not remove anything. The sword is still there only if its entity is alive
;; AND it is still a sword (KIND_SWORD): its slot may have been freed, or taken by
;; another entity (a cloud of smoke, for example).
;; If there is no sword, it does nothing.
;; ❌ May modify A, HL
sys_sword_update::
   INCBIN "bin/sys_sword_update.bin"      ;; Rutina dada, en binario (22 bytes)
