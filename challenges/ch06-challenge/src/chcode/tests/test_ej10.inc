SECTION "Test ej10", ROM0

;;--------------------------------------------------------------
;; Ejercicio 10 · sys_prerender_one
;;--------------------------------------------------------------
test_ej10::
   ;; CASO 1 · sin flip
   call tst_reset
   tst_set8 cam_x, 50
   tst_set8 cam_y, 20
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_Y, 60
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_X, 100
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TILE, 80
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_ATTR, 0
   tst_set8 shadow_cursor, 40
   tst_fill shadow_oam, 96, $EE
   ld   de, entity_array
   call ej10
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej10.asm

   ;; CASO 2 · con flip
   call tst_reset
   tst_set8 cam_x, 50
   tst_set8 cam_y, 20
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_Y, 60
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_X, 100
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TILE, 80
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_ATTR, $20
   tst_set8 shadow_cursor, 16
   tst_fill shadow_oam, 96, $EE
   ld   de, entity_array
   call ej10
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej10.asm

   ret
