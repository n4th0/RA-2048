;;=============================================================================
;; entity_manager.asm — Gestor de entidades del motor ECS
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Las entidades viven en un array de MAX_ENTITIES structs de SIZEOF_ENTITY
;; bytes. Los sistemas solo saben procesar UNA entidad; el gestor es quien
;; sabe recorrerlas todas (man_entity_for_each).
;;=============================================================================
INCLUDE "constants.inc"

;; ALIGN[8]: el array empieza en $xx00. Así, para avanzar de una entidad a la
;; siguiente basta con sumar a E: D nunca cambia mientras el array quepa en 256.
SECTION "Entities", WRAM0, ALIGN[8]
entity_array:: DS MAX_ENTITIES * SIZEOF_ENTITY
entity_array_end:

ASSERT MAX_ENTITIES * SIZEOF_ENTITY <= 256, "el array de entidades no cabe en 256 bytes: for_each dejaría de funcionar"

SECTION "Entity Manager CODE", ROM0

;;-----------------------------------------------------------------------------
;; man_entity_init: deja todas las entidades libres (array entero a 0).
;; Modifica: A, F, B, HL
man_entity_init::
   ld hl, entity_array
   ld b, MAX_ENTITIES * SIZEOF_ENTITY
   xor a
.clear:
   ld [hl+], a
   dec b
   jr nz, .clear
   ret

;;-----------------------------------------------------------------------------
;; man_entity_alloc: busca una entidad libre, la marca como usada y pone a 0
;; el resto de sus campos.
;; 📤 DE = entidad reservada y carry a 0, o carry a 1 si el array está lleno
;; Modifica: A, F, B, DE
man_entity_alloc::
   ld de, entity_array
   ld b, MAX_ENTITIES
.find:
   ld a, [de]               ;; E_ACTIVE es el campo 0
   or a
   jr z, .found
   ld a, e
   add SIZEOF_ENTITY
   ld e, a
   dec b
   jr nz, .find
   scf                      ;; lleno: lo indica el carry
   ret
.found:
   push de
   ld a, 1
   ld [de], a               ;; E_ACTIVE = 1
   inc de
   xor a
   ld b, SIZEOF_ENTITY - 1
.clear_fields:
   ld [de], a
   inc de
   dec b
   jr nz, .clear_fields
   pop de                   ;; xor a dejó carry a 0: éxito
   ret

;;-----------------------------------------------------------------------------
;; man_entity_for_each: llama a una rutina por cada entidad activa.
;; 📥 HL = rutina. La recibe con DE = entidad y puede modificar cualquier
;;        registro: aquí se guardan BC, DE y HL antes de llamarla.
;; Modifica: A, F, BC, DE
man_entity_for_each::
   ld de, entity_array
   ld b, MAX_ENTITIES
.loop:
   ld a, [de]               ;; ¿E_ACTIVE?
   or a
   jr z, .next
   push bc
   push de
   push hl
   call .call_hl            ;; la SM83 no tiene "call hl": se simula (sesión 06.1)
   pop hl
   pop de
   pop bc
.next:
   ld a, e
   add SIZEOF_ENTITY
   ld e, a
   dec b
   jr nz, .loop
   ret
.call_hl:
   jp hl                    ;; la dirección de vuelta ya está en la pila por el call

;;-----------------------------------------------------------------------------
;; man_entity_at: ¿hay alguna entidad activa en la casilla (B, C)?
;; Recorre el array directamente (sin for_each) para poder salir en cuanto
;; encuentra una.
;; 📥 B = fila, C = columna
;; 📤 carry a 1 si está ocupada (HL = esa entidad), carry a 0 si está libre
;; Modifica: A, F, E, HL
man_entity_at::
   ld hl, entity_array
   ld e, MAX_ENTITIES
.check:
   ld a, [hl]               ;; E_ACTIVE
   or a
   jr z, .next
   inc l                    ;; E_TYPE
   inc l                    ;; E_Y (inc l basta: el array no cruza un bloque de 256)
   ld a, [hl+]              ;; A = E_Y, HL -> E_X
   cp b
   jr nz, .rewind
   ld a, [hl]               ;; E_X
   cp c
   jr nz, .rewind
   ld a, l                  ;; ocupada: HL vuelve al inicio de la entidad
   sub E_X
   ld l, a
   scf
   ret
.rewind:
   ld a, l                  ;; HL apunta a E_Y o E_X: volvemos al inicio
   and ~(SIZEOF_ENTITY - 1) ;; vale porque SIZEOF_ENTITY es potencia de 2
   ld l, a
.next:
   ld a, l
   add SIZEOF_ENTITY
   ld l, a
   dec e
   jr nz, .check
   and a                    ;; libre: carry a 0
   ret

ASSERT SIZEOF_ENTITY == 8, "man_entity_at asume SIZEOF_ENTITY potencia de 2 (8)"
