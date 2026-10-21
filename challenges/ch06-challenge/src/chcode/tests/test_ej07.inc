SECTION "Test ej07", ROM0

;;--------------------------------------------------------------
;; Ejercicio 7 · portal_spawn
;;--------------------------------------------------------------
test_ej07::
   ;; CASO 1 · nivel 3
   call tst_reset
   tst_set8 level_current, 2
   call ej07
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej07.asm

   ;; CASO 2 · sin hueco
   call tst_reset
   call tst_alive_all
   tst_set8 level_current, 2
   call ej07
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej07.asm

   ret
