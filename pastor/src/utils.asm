INCLUDE "hardware.inc"

SECTION "Utils", ROM0

;; wait_vblank: espera al INICIO del siguiente VBLANK.
;; Primero espera a salir de la línea 144 por si ya estábamos en ella:
;; en el mismo frame.
;; Modifica: A, F
wait_vblank::
.leave_line_144:
   ld a, [rLY]
   cp 144
   jr z, .leave_line_144
.wait_line_144:
   ld a, [rLY]
   cp 144
   jr nz, .wait_line_144
   ret

;; Modifica: A, F
lcd_off::
   ld a, [rLCDC]
   bit 7, a                 ;; bit 7 = pantalla encendida
   ret z
   call wait_vblank
   xor a                    ;; rLCDC = 0: pantalla apagada (lcd_on lo vuelve a configurar todo)
   ld [rLCDC], a
   ret


lcd_on::
   ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON
   ld [rLCDC], a
   ret


memcpy::
   ld a, [hl+]
   ld [de], a
   inc de
   dec bc
   ld a, b                  ;; dec bc no actualiza flags: comprobamos BC == 0 a mano.
   or c                     ;; B OR C solo da 0 si B y C valen 0 a la vez
   jr nz, memcpy
   ret
