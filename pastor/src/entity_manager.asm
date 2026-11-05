
INCLUDE "constants.inc"

;; ALIGN[8]: el array empieza en $xx00. Como ocupa
;; menos de 256 bytes, la parte alta de la dirección no cambia nunca: para
;; pasar de una entidad a la siguiente basta con sumar a la parte baja.
SECTION "Entities", WRAM0, ALIGN[8]
entity_array:: DS MAX_ENTITIES * SIZEOF_ENTITY

SECTION "Entity Manager state", WRAM0
for_each_routine: DS 2       

SECTION "Entity Manager CODE", ROM0


man_entity_init::
   ld hl, entity_array
   ld b, MAX_ENTITIES * SIZEOF_ENTITY
   xor a
.clear:
   ld [hl+], a
   dec b
   jr nz, .clear
   ret


man_entity_alloc::
   ld de, entity_array
   ld b, MAX_ENTITIES
.find:
   ld a, [de]               
   cp 0
   jr z, .found
   ld a, e                  
   add SIZEOF_ENTITY
   ld e, a
   dec b
   jr nz, .find
   scf                      
   ret
.found:
   push de
   ld a, 1
   ld [de], a               
   inc de
   xor a                     
   ld b, SIZEOF_ENTITY - 1
.clear_fields:
   ld [de], a
   inc de
   dec b
   jr nz, .clear_fields
   pop de
   ret


man_entity_for_each::
   ld a, l                  ;; guardar la rutina
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
   jp hl                    ;; 3) saltar
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
