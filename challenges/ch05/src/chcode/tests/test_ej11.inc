SECTION "Test ej11", ROM0

;;--------------------------------------------------------------
;; Ejercicio 11 · scene_menu_update, scene_gameover_update
;;--------------------------------------------------------------
test_ej11::
   ;; CASO 1 · A en el menú
   call tst_reset
   tst_set16 scene_current, scene_menu
   tst_set8 input_pressed, BTN_A
   call ej11a
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej11.asm

   ;; CASO 2 · A en Game Over
   call tst_reset
   tst_set16 scene_current, scene_gameover
   tst_set8 input_pressed, BTN_A
   call ej11b
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej11.asm

   ret
