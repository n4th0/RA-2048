SECTION "Test ej01", ROM0

;;--------------------------------------------------------------
;; Ejercicio 1 · dma_init
;;--------------------------------------------------------------
test_ej01::
   ;; CASO 1 · dma_init
   call tst_reset
   tst_fill hDMARoutine, 16, $EE
   call ej01
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej01.asm

   ;; CASO 2 · la copia
   call tst_reset
   call screen_off
   tst_fill OAM_START, 160, $FF
   tst_ramp_at shadow_oam, 160, 0
   call ej01
   call hDMARoutine
   ld   b, b       ;; ✔ Compara con el RESULTADO ESPERADO de ej01.asm

   ret
