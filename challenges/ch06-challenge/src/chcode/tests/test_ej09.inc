SECTION "Test ej09", ROM0

;;--------------------------------------------------------------
;; Ejercicio 9 · world_to_oam
;;--------------------------------------------------------------
test_ej09::
   ;; CASO 1 · dentro de la pantalla
   call tst_reset
   tst_set8 cam_x, 50
   tst_set8 cam_y, 20
   ld   hl, $1234
   ld   d, 60
   ld   e, 100
   call ej09
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej09.asm

   ;; CASO 2 · fuera de la pantalla
   call tst_reset
   tst_set8 cam_x, 50
   tst_set8 cam_y, 20
   ld   hl, $1234
   ld   d, 2
   ld   e, 3
   call ej09
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej09.asm

   ret
