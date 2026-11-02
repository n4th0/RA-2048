
;; Las entidades viven en un array de MAX_ENTITIES structs de SIZEOF_ENTITY
;; bytes. Los sistemas solo saben procesar UNA entidad; el gestor es quien
;; sabe recorrerlas todas (man_entity_for_each).
INCLUDE "constants.inc"

;; ALIGN[8]: el array empieza en $xx00. Como ocupa
;; menos de 256 bytes, la parte alta de la dirección no cambia nunca: para
;; pasar de una entidad a la siguiente basta con sumar a la parte baja.
SECTION "Entities", WRAM0, ALIGN[8]
entity_array:: DS MAX_ENTITIES * SIZEOF_ENTITY

SECTION "Entity Manager state", WRAM0
for_each_routine: DS 2       ;; rutina que está llamando man_entity_for_each

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
   cp 0
   jr z, .found
   ld a, e                  ;; siguiente entidad (solo cambia la parte baja)
   add SIZEOF_ENTITY
   ld e, a
   dec b
   jr nz, .find
   scf                      ;; lleno: lo indicamos con el carry a 1
   ret
.found:
   push de
   ld a, 1
   ld [de], a               ;; E_ACTIVE = 1
   inc de
   xor a                    ;; A = 0 (y carry a 0: lo devolvemos así)
   ld b, SIZEOF_ENTITY - 1
.clear_fields:
   ld [de], a
   inc de
   dec b
   jr nz, .clear_fields
   pop de
   ret

;;-----------------------------------------------------------------------------
;; man_entity_for_each: llama a una rutina por cada entidad activa.
;; La SM83 no tiene "call hl", así que se simula como en la sesión 06.1:
;; se mete en la pila la dirección de vuelta y se salta con jp hl. El ret
;; de la rutina vuelve a .back.
;; 📥 HL = rutina. La recibe con DE = entidad y puede modificar cualquier
;;        registro: aquí se guardan BC y DE antes de llamarla.
;; ⚠️ La rutina NO puede llamar a su vez a man_entity_for_each (pisaría
;;    for_each_routine).
;; Modifica: A, F, BC, DE, HL
man_entity_for_each::
   ld a, l                  ;; guardar la rutina: HL lo necesitamos para saltar
   ld [for_each_routine], a
   ld a, h
   ld [for_each_routine + 1], a

   ld de, entity_array
   ld b, MAX_ENTITIES
.loop:
   ld a, [de]               ;; ¿E_ACTIVE?
   cp 0
   jr z, .next
   push bc
   push de
   ld hl, .back             ;; 1) apuntar la vuelta en la pila
   push hl
   ld a, [for_each_routine] ;; 2) HL = rutina
   ld l, a
   ld a, [for_each_routine + 1]
   ld h, a
   jp hl                    ;; 3) saltar (su ret vuelve a .back)
.back:
   pop de
   pop bc
.next:
   ld a, e                  ;; siguiente entidad
   add SIZEOF_ENTITY
   ld e, a
   dec b
   jr nz, .loop
   ret

;;-----------------------------------------------------------------------------
;; man_entity_at: ¿hay alguna entidad activa en la casilla (B, C)?
;; 📥 B = fila, C = columna
;; 📤 carry a 1 si está ocupada, carry a 0 si está libre
;; Modifica: A, F, E, HL
man_entity_at::
   ld hl, entity_array
   ld e, MAX_ENTITIES
.check:
   ld a, [hl]               ;; E_ACTIVE
   cp 0
   jr z, .next
   ld a, l                  ;; HL = &E_Y de esta entidad
   add E_Y
   ld l, a
   ld a, [hl+]              ;; A = E_Y, y HL pasa a apuntar a E_X
   cp b
   jr nz, .back
   ld a, [hl]               ;; A = E_X
   cp c
   jr nz, .back
   scf                      ;; misma fila y misma columna: ocupada
   ret
.back:
   ld a, l                  ;; HL apunta a E_X: volver al inicio de la entidad
   sub E_X
   ld l, a
.next:
   ld a, l
   add SIZEOF_ENTITY
   ld l, a
   dec e
   jr nz, .check
   xor a                    ;; libre: carry a 0
   ret
