SECTION "Test ej06", ROM0

;;--------------------------------------------------------------
;; Ejercicio 6 · sys_prerender_one
;;--------------------------------------------------------------
test_ej06::
   ;; CASO 1 · entidad con sprite
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_fill shadow_oam, 16, $EE
   tst_set8 shadow_cursor, 8
   ld   de, entity_array
   call ej06
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej06.asm

   ;; CASO 2 · entidad sin sprite
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_PHYSICS, 50, 60, 7, 0, 0, 0, KIND_ENEMY
   tst_fill shadow_oam, 16, $EE
   tst_set8 shadow_cursor, 8
   ld   de, entity_array
   call ej06
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej06.asm

   ret
