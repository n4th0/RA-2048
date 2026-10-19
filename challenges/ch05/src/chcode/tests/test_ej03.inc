SECTION "Test ej03", ROM0

;;--------------------------------------------------------------
;; Ejercicio 3 · sys_physics_one
;;--------------------------------------------------------------
test_ej03::
   ;; CASO 1 · un asteroide se mueve
   call tst_reset
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 50, 80, TILE_ASTEROID_A, 0, 2, 255, KIND_ENEMY
   ld   de, entity_array + 1 * SIZEOF_ENTITY
   call ej03
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej03.asm

   ;; CASO 2 · rebota por la izquierda
   call tst_reset
   tst_ent 1, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 50, 0, TILE_ASTEROID_A, 0, 1, 255, KIND_ENEMY
   ld   de, entity_array + 1 * SIZEOF_ENTITY
   call ej03
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej03.asm

   ret
