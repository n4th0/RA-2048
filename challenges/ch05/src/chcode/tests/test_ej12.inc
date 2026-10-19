SECTION "Test ej12", ROM0

;;--------------------------------------------------------------
;; Ejercicio 12 · game_handle_collisions
;;--------------------------------------------------------------
test_ej12::
   ;; CASO 1 · un disparo rompe una moneda
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 60, 100, TILE_SHOT, 0, -SHOT_SPEED, 0, KIND_SHOT
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   tst_ent 2, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 62, 100, TILE_BONUS, 0, 0, 0, KIND_BONUS
   call ej12
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej12.asm

   ;; CASO 2 · un disparo rompe un asteroide
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 60, 100, TILE_SHOT, 0, -SHOT_SPEED, 0, KIND_SHOT
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   tst_ent 2, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 62, 100, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   tst_ent 3, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 62, 100, TILE_BONUS, 0, 0, 0, KIND_BONUS
   call ej12
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej12.asm

   ret
