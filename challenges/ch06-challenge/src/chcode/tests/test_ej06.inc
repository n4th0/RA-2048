SECTION "Test ej06", ROM0

;;--------------------------------------------------------------
;; Ejercicio 6 · game_enemies_spawn
;;--------------------------------------------------------------
test_ej06::
   ;; CASO 1 · 3 enemigos
   call tst_reset
   tst_set8 tst_data + 0, 3
   tst_set8 tst_data + 1, 3
   tst_set8 tst_data + 2, 2
   tst_set8 tst_data + 3, 4
   tst_set8 tst_data + 4, 20
   tst_set8 tst_data + 5, 30
   tst_set8 tst_data + 6, 9
   ld   hl, tst_data
   call ej06
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej06.asm

   ;; CASO 2 · ningún enemigo
   call tst_reset
   tst_set8 tst_data, 0
   tst_set8 enemies_left, 99
   ld   hl, tst_data
   call ej06
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej06.asm

   ret
