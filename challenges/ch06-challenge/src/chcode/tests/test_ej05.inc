SECTION "Test ej05", ROM0

;;--------------------------------------------------------------
;; Ejercicio 5 · hud_show, hud_draw_hearts
;;--------------------------------------------------------------
test_ej05::
   ;; CASO 1 · dos corazones
   call tst_reset
   call screen_off
   tst_fill rWY, 2, 0
   tst_fill HUD_HEARTS_CELL, 3, $EE
   call ej05a
   ld   c, 2
   call ej05b
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej05.asm

   ;; CASO 2 · ningún corazón
   call tst_reset
   call screen_off
   tst_fill rWY, 2, 0
   tst_fill HUD_HEARTS_CELL, 3, $EE
   call ej05a
   ld   c, 0
   call ej05b
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej05.asm

   ret
