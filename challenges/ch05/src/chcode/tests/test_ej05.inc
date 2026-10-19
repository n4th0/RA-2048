SECTION "Test ej05", ROM0

;;--------------------------------------------------------------
;; Ejercicio 5 · sys_shot_update
;;--------------------------------------------------------------
test_ej05::
   ;; CASO 1 · el disparo sigue ahí
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 100, 60, TILE_SHOT, 0, -SHOT_SPEED, 0, KIND_SHOT
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   call ej05
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej05.asm

   ;; CASO 2 · ya no es el disparo
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 100, 60, TILE_SHOT, 0, -SHOT_SPEED, 0, KIND_SHOT
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   tst_set8 entity_array + 1 * SIZEOF_ENTITY, 0
   call ej05
   ld   a, [shot_entity]
   ld   [tst_log], a
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 100, 60, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   call ej05
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej05.asm

   ret
