SECTION "Test ej08", ROM0

;;--------------------------------------------------------------
;; Ejercicio 8 · sys_ai_choose
;;--------------------------------------------------------------
test_ej08::
   ;; CASO 1 · se queda quieta
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_AI
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VY, 1
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VX, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_DIR, 0
   ld   de, entity_array
   ld   a, %00110101
   call ej08
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej08.asm

   ;; CASO 2 · camina
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_CMP, CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_AI
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VY, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_VX, 0
   tst_set8 entity_array + 0 * SIZEOF_ENTITY + E_DIR, 0
   ld   de, entity_array
   ld   a, %01100000
   call ej08
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej08.asm

   ret
