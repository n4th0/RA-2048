;;=============================================================================
;; joypad.asm — Lectura del mando
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; rP1 ($FF00) devuelve los botones en bajo (0 = pulsado) y solo un grupo a la
;; vez: primero se elige la cruceta, luego los botones (sesión 02.2).
;; Aquí los dejamos en positivo (1 = pulsado) con el formato de hardware.inc:
;; cruceta en el nibble alto (PADF_DOWN..PADF_RIGHT), botones en el bajo.
;;=============================================================================
INCLUDE "hardware.inc"

SECTION "Joypad state", WRAM0
joypad_state::   DS 1   ;; botones pulsados ahora mismo
joypad_pressed:: DS 1   ;; botones que se han pulsado ESTE frame (no estaban antes)

SECTION "Joypad CODE", ROM0

;;-----------------------------------------------------------------------------
;; joypad_read: actualiza joypad_state y joypad_pressed. Llamar una vez por frame.
;; joypad_pressed servirá para menús: un toque = una acción, aunque se mantenga.
;; Modifica: A, F, B, C
joypad_read::
   ld a, P1F_GET_DPAD
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]             ;; se lee 2 veces: las líneas tardan en estabilizarse
   cpl                      ;; 1 = pulsado
   and $0F
   swap a                   ;; cruceta al nibble alto
   ld b, a

   ld a, P1F_GET_BTN
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]             ;; los botones necesitan más tiempo (como en Pan Docs)
   cpl
   and $0F
   or b
   ld b, a                  ;; B = estado nuevo

   ld a, P1F_GET_NONE       ;; deseleccionar: reduce consumo y ruido
   ldh [rP1], a

   ld a, [joypad_state]     ;; pressed = nuevo AND NOT anterior
   cpl
   and b
   ld [joypad_pressed], a
   ld a, b
   ld [joypad_state], a
   ret
