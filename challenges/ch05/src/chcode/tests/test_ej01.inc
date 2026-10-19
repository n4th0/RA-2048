SECTION "Test ej01", ROM0

;;--------------------------------------------------------------
;; Ejercicio 1 · man_entity_alloc
;;--------------------------------------------------------------
test_ej01::
   ;; CASO 1 · hay un hueco
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 40, 60, TILE_ASTEROID_A, 0, 0, 0, KIND_ENEMY
   ld   b, $5A
   ld   de, $1234
   ld   a, CMP_SPRITE | CMP_PHYSICS
   call ej01
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej01.asm

   ;; CASO 2 · array lleno
   call tst_reset
   call tst_alive_all
   ld   b, $5A
   ld   de, $1234
   ld   a, CMP_SPRITE
   call ej01
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej01.asm

   ret
