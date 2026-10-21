SECTION "Test ej03", ROM0

;;--------------------------------------------------------------
;; Ejercicio 3 · sys_render_scroll
;;--------------------------------------------------------------
test_ej03::
   ;; CASO 1 · caso normal
   call tst_reset
   call screen_off
   tst_set8 cam_x, 48
   tst_set8 cam_y, 30
   tst_fill rSCY, 2, $FF
   call ej03
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej03.asm

   ;; CASO 2 · la cámara al máximo
   call tst_reset
   call screen_off
   tst_set8 cam_x, 96
   tst_set8 cam_y, 112
   tst_fill rSCY, 2, $FF
   call ej03
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej03.asm

   ret
