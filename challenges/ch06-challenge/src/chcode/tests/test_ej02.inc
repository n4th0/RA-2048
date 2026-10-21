SECTION "Test ej02", ROM0

;;--------------------------------------------------------------
;; Ejercicio 2 · camera_axis
;;--------------------------------------------------------------
test_ej02::
   ;; CASO 1 · caso normal
   call tst_reset

   ld   a, 120
   ld   b, 72
   ld   c, 160
   call ej02
   ld   [tst_log], a
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej02.asm

   ;; CASO 2 · los límites
   call tst_reset

   ld   a, 30
   ld   b, 72
   ld   c, 160
   call ej02
   ld   [tst_log], a
   ld   a, 250
   ld   b, 72
   ld   c, 160
   call ej02
   ld   [tst_log + 1], a
   ld   a, 250
   ld   b, 64
   ld   c, 144
   call ej02
   ld   [tst_log + 2], a
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej02.asm

   ret
