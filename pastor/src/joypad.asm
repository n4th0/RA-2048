;;=============================================================================
;; joypad.asm — Lectura del mando
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Como en la sesión 02.2: se escribe en $FF00 qué grupo se quiere leer
;; ($20 = cruceta, $10 = botones) y se leen los bits 3..0, donde 0 = pulsado.
;; Aquí los damos la vuelta (1 = pulsado) para que `bit` sea más natural.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Joypad state", WRAM0
joypad_dpad::    DS 1   ;; cruceta pulsada ahora (bits PAD_*)
joypad_buttons:: DS 1   ;; botones pulsados ahora (bits BTN_*)
joypad_pressed:: DS 1   ;; botones que se han pulsado ESTE frame (no estaban antes)

SECTION "Joypad CODE", ROM0

;;-----------------------------------------------------------------------------
;; joypad_read: actualiza joypad_dpad, joypad_buttons y joypad_pressed.
;; Llamar una vez por frame.
;; joypad_pressed sirve para START: un toque = una acción, aunque se mantenga.
;; Modifica: A, F, B
joypad_read::
   ;;--- Cruceta ---
   ld a, $20
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]             ;; se lee 2 veces: las líneas tardan en estabilizarse
   and %00001111            ;; solo nos interesan los bits 3..0
   xor %00001111            ;; dar la vuelta: ahora 1 = pulsado
   ld [joypad_dpad], a

   ;;--- Botones ---
   ld a, $10
   ldh [rP1], a
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]
   ldh a, [rP1]             ;; los botones tardan más en estabilizarse
   and %00001111
   xor %00001111
   ld b, a                  ;; B = botones ahora

   ;;--- Recién pulsados = pulsados ahora Y NO pulsados antes ---
   ld a, [joypad_buttons]   ;; A = botones antes
   xor %00001111            ;; A = botones NO pulsados antes
   and b
   ld [joypad_pressed], a
   ld a, b
   ld [joypad_buttons], a

   ld a, $30                ;; no seleccionar ningún grupo
   ldh [rP1], a
   ret
