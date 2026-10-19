SECTION "Test ej07", ROM0

;;--------------------------------------------------------------
;; Ejercicio 7 · sys_prerender_update
;;--------------------------------------------------------------
test_ej07::
   ;; CASO 1 · 2 entidades con sprite
   call tst_reset
   tst_ent 0, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT, SHIP_Y, SHIP_X_START, TILE_SHIP, 0, 0, 0, KIND_SHIP
   tst_ent 2, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER, 60, 70, TILE_ASTEROID_B, 0, 0, 0, KIND_ENEMY
   tst_fill shadow_oam, 32, $EE
   tst_set8 shadow_cursor, $14
   call ej07
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej07.asm

   ;; CASO 2 · ninguna entidad
   call tst_reset
   tst_fill shadow_oam, 32, $EE
   call ej07
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej07.asm

   ret
