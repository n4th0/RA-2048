SECTION "Test ej04", ROM0

;;--------------------------------------------------------------
;; Ejercicio 4 · sys_shot_spawn
;;--------------------------------------------------------------
test_ej04::
   ;; CASO 1 · no hay disparo
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   ld   d, 100
   ld   e, 50
   call ej04
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej04.asm

   ;; CASO 2 · ya hay un disparo
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 20, 30, TILE_SHOT, 0, -SHOT_SPEED, 0, KIND_SHOT
   tst_set8 shot_entity, LOW(entity_array + 1 * SIZEOF_ENTITY)
   ld   d, 100
   ld   e, 50
   call ej04
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej04.asm

   ret
