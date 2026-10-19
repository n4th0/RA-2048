SECTION "Test ej02", ROM0

;;--------------------------------------------------------------
;; Ejercicio 2 · man_entity_for_each
;;--------------------------------------------------------------
test_ej02::
   ;; CASO 1 · 3 entidades vivas
   call tst_reset
   tst_set8 entity_array + 0 * SIZEOF_ENTITY, CMP_ALIVE
   tst_set8 entity_array + 2 * SIZEOF_ENTITY, CMP_ALIVE
   tst_set8 entity_array + 5 * SIZEOF_ENTITY, CMP_ALIVE
   ld   hl, tst_cb_log
   call ej02
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej02.asm

   ;; CASO 2 · 8 entidades vivas
   call tst_reset
   call tst_alive_all
   ld   hl, tst_cb_log
   call ej02
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej02.asm

   ret
