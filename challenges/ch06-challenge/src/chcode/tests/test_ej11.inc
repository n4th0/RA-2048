SECTION "Test ej11", ROM0

;;--------------------------------------------------------------
;; Ejercicio 11 · sys_animation_one
;;--------------------------------------------------------------
test_ej11::
   ;; CASO 1 · camina, y el portal
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_ANIMATION
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VY, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VX, $FF
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_DIR, 2
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TICK, 7
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_SHEET, 80
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_ATTR, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TILE, 0
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_ANIMATION
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_DIR, 0
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_TICK, 7
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_SHEET, 136
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_ATTR, 0
   tst_set8 entity_array + 1 * SIZEOF_ENTITY + E_TILE, 0
   ld   de, entity_array
   call ej11
   ld   de, entity_array + SIZEOF_ENTITY
   call ej11
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej11.asm

   ;; CASO 2 · quieta
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_ANIMATION
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VY, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VX, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_DIR, 1
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TICK, 13
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_SHEET, 80
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_ATTR, $30
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TILE, 0
   ld   de, entity_array
   call ej11
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej11.asm

   ret
