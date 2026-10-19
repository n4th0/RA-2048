;;==============================================================
;; Challenge 5 · Gestor de entidades (Entity Manager)
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
;; EJERCICIO 01: `man_entity_alloc`
;; La implementas TÚ, en src/ej01.asm (etiqueta `ej01::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `man_entity_alloc` y no necesita saber dónde está tu código.
man_entity_alloc::
   jp   go_ej01              ;; Salta al ejercicio 01 (ver main.asm)
   ds   22, $00              ;; Relleno: las demás rutinas conservan su dirección

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
;; EJERCICIO 02: `man_entity_for_each`
;; La implementas TÚ, en src/ej02.asm (etiqueta `ej02::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `man_entity_for_each` y no necesita saber dónde está tu código.
man_entity_for_each::
   jp   go_ej02              ;; Salta al ejercicio 02 (ver main.asm)
   ds   24, $00              ;; Relleno: las demás rutinas conservan su dirección
