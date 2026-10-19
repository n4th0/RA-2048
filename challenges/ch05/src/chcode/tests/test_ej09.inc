SECTION "Test ej09", ROM0

;;--------------------------------------------------------------
;; Ejercicio 9 · sys_collision_overlaps
;;--------------------------------------------------------------
test_ej09::
   ;; CASO 1 · se solapan
   call tst_reset
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 50, 50, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_ent 2, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 53, 56, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   ld   de, entity_array + 1 * SIZEOF_ENTITY
   ld   hl, entity_array + 2 * SIZEOF_ENTITY
   call ej09
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej09.asm

   ;; CASO 2 · lejos en X
   call tst_reset
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 50, 50, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_ent 2, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 50, 57, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   ld   de, entity_array + 1 * SIZEOF_ENTITY
   ld   hl, entity_array + 2 * SIZEOF_ENTITY
   call ej09
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej09.asm

   ret
