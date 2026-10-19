SECTION "Test ej08", ROM0

;;--------------------------------------------------------------
;; Ejercicio 8 · sys_render_update
;;--------------------------------------------------------------
test_ej08::
   ;; CASO 1 · copia a los sprites 8-15
   call tst_reset
   tst_ramp_at shadow_oam, 160, 0
   call ej08
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej08.asm

   ;; CASO 2 · solo copia 32 bytes
   call tst_reset
   call wait_vblank
   tst_fill OAM_START, 96, $77
   tst_ramp_at shadow_oam, 160, $80
   call ej08
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej08.asm

   ret
