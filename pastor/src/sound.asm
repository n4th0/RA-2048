;;=============================================================================
;; sound.asm — Efectos cortos con el canal de pulso 1 del DMG
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================

SECTION "Sound CODE", ROM0

;; Encender la APU, fijar volumen y enviar el canal 1 a ambos altavoces.
;; Llamar una vez durante la inicialización.
sfx_init::
   ld a, $80
   ldh [$FF26], a           ;; NR52: APU encendida
   ld a, $77
   ldh [$FF24], a           ;; NR50: volumen izquierdo y derecho
   ld a, $11
   ldh [$FF25], a           ;; NR51: canal 1 en ambos lados
   ret

;; Tono breve cuando una oveja queda encerrada.
sfx_sheep_in::
   xor a
   ldh [$FF10], a           ;; NR10: sin barrido
   ld a, $A8
   ldh [$FF11], a           ;; NR11: pulso al 50%, duración corta
   ld a, $F2
   ldh [$FF12], a           ;; NR12: volumen alto con caída
   ld a, $00
   ldh [$FF13], a           ;; NR13: frecuencia baja
   ld a, $C7
   ldh [$FF14], a           ;; NR14: iniciar tono, activar longitud
   ret

;; Tono más agudo al completar un nivel.
sfx_level_clear::
   xor a
   ldh [$FF10], a           ;; NR10: sin barrido
   ld a, $A4
   ldh [$FF11], a           ;; NR11: pulso al 50%, algo más largo
   ld a, $F3
   ldh [$FF12], a           ;; NR12: volumen alto con caída
   ld a, $6E
   ldh [$FF13], a           ;; NR13: frecuencia más aguda que el aviso de oveja
   ld a, $C7
   ldh [$FF14], a           ;; NR14: iniciar tono, activar longitud
   ret
