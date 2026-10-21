SECTION "Test ej12", ROM0

;;--------------------------------------------------------------
;; Ejercicio 12 · sys_animation_image
;;--------------------------------------------------------------
test_ej12::
   ;; CASO 1 · camina a la izquierda
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_ANIMATION
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VY, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VX, $FF
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_DIR, 2
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TICK, 7
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_SHEET, 80
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_ATTR, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_TILE, 0
   ld   de, entity_array
   call ej12
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej12.asm

   ;; CASO 2 · mira hacia arriba
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
   call ej12
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej12.asm

   ret
