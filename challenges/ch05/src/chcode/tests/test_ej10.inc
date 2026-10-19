SECTION "Test ej10", ROM0

;;--------------------------------------------------------------
;; Ejercicio 10 · sys_collision_one
;;--------------------------------------------------------------
test_ej10::
   ;; CASO 1 · la candidata choca
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 3, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 140, 88, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_set16 collision_probe, entity_array
   tst_set8 collision_mask, KIND_ENEMY
   ld   de, entity_array + 3 * SIZEOF_ENTITY
   call ej10
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej10.asm

   ;; CASO 2 · la sonda ya ha golpeado
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 3, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 140, 88, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_set16 collision_probe, entity_array
   tst_set8 collision_mask, KIND_ENEMY
   tst_set8 collision_hits, 1
   ld   de, entity_array + 3 * SIZEOF_ENTITY
   call ej10
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej10.asm

   ret
