SECTION "Test ej04", ROM0

;;--------------------------------------------------------------
;; Ejercicio 4 · map_tile_address
;;--------------------------------------------------------------
test_ej04::
   ;; CASO 1 · un punto del medio
   call tst_reset
   tst_set16 map_current, Level1Map
   ld   d, 27
   ld   e, 4
   call ej04
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej04.asm

   ;; CASO 2 · la última esquina
   call tst_reset
   tst_set16 map_current, Level1Map
   ld   d, 31
   ld   e, 31
   call ej04
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej04.asm

   ret
