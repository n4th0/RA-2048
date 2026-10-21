;;==============================================================
;; Challenge 6 · Gestor de entidades (Entity Manager)
;; Un gestor de entidades es un concepto independiente de las escenas:
;; cada escena que lo necesita lo inicia y lo usa.
;; Solo sabe de entidades: reservar, liberar y recorrer. Nada de dibujar,
;; mover ni colisionar.
;;==============================================================
INCLUDE "man/man_entity.inc"

;; ALIGN[8]: the array starts at an address ending in $00 and is smaller
;; than 256 bytes. Walking through it only changes L, never H.
SECTION "Entity array", WRAM0, ALIGN[8]
entity_array::   DS ENTITY_ARRAY_SIZE

SECTION "Entity manager", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frees every entity.
;; ❌ Modifies A, B, HL
man_entity_init::
   INCBIN "bin/man_entity_init.bin"       ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Looks for a free entity and reserves it.
;; 📥 INPUT:   A: components the new entity will have (CMP_SPRITE, ...)
;; ⫷▬ RETURNS: Z,  HL = address of the entity, and [HL] = A | CMP_ALIVE
;;             NZ, there is no free entity
;; ❌ May modify A, BC, HL. Must NOT modify DE
;; ⚠️ It does not change the other fields: the caller fills them in
man_entity_alloc::
   INCBIN "bin/man_entity_alloc.bin"      ;; Rutina dada, en binario (26 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates an entity from a TEMPLATE: a block of SIZEOF_ENTITY bytes in ROM
;; with the initial values of every field (its CMP must include CMP_ALIVE).
;; It reserves an entity (man_entity_alloc) and copies the template (memcpy8).
;; The caller only has to change the fields that depend on the situation.
;; 📥 INPUT:   HL: template
;; ⫷▬ RETURNS: Z,  HL = address of the new entity
;;             NZ, there is no free entity
;; ❌ May modify A, BC, HL. Does NOT modify DE
man_entity_create::
   INCBIN "bin/man_entity_create.bin"     ;; Rutina dada, en binario (27 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frees one entity: it stops existing for every system.
;; 📥 DE = entity
;; ❌ Modifies A
man_entity_free::
   INCBIN "bin/man_entity_free.bin"       ;; Rutina dada, en binario (3 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calls a routine once for every entity that is alive.
;; It is man_entity_for_each_matching without required components.
;; 📥 INPUT: HL: address of the routine to call
;;           The routine receives DE = the entity, and it may modify
;;           every register: for_each looks after its own state.
;; ❌ May modify A, BC, DE, HL
;; ⚠️ Use "call call_hl" to call the routine whose address is in HL
man_entity_for_each::
   INCBIN "bin/man_entity_for_each.bin"   ;; Rutina dada, en binario (2 bytes)
                                ;; (and it goes on with the routine below)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calls a routine once for every entity that is alive AND has ALL the components
;; in a mask. The routine does not have to check them: for it, they are a precondition.
;; 📥 INPUT: HL: address of the routine to call
;;           C: required components (CMP_xxx | CMP_yyy ...). ALIVE is always required
;;           The routine receives DE = the entity, and it may modify
;;           every register: for_each looks after its own state.
;; ❌ May modify A, BC, DE, HL
;; ⚠️ Use "call call_hl" to call the routine whose address is in HL
man_entity_for_each_matching::
   INCBIN "bin/man_entity_for_each_matching.bin" ;; Rutina dada, en binario (31 bytes)
