;;=============================================================================
;; utils.asm — Rutinas de uso general (sincronización, pantalla, memoria)
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "hardware.inc"

SECTION "Utils", ROM0

;;-----------------------------------------------------------------------------
;; wait_vblank: espera al INICIO del siguiente VBLANK.
;; Primero espera a salir de la línea 144 por si ya estábamos en ella:
;; si el bucle del juego fuese muy rápido, sin esto se ejecutaría dos veces
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

;;-----------------------------------------------------------------------------
;; lcd_off: apaga la pantalla para poder escribir en VRAM sin límite de tiempo.
;; Apagarla fuera del VBLANK puede dañar el LCD de una Game Boy real,
;; por eso esperamos al VBLANK antes.
;; Si ya está apagada no hace nada: con el LCD apagado rLY se queda en 0
;; y wait_vblank esperaría para siempre.
;; Modifica: A, F
lcd_off::
   ld a, [rLCDC]
   bit 7, a                 ;; bit 7 = pantalla encendida
   ret z
   call wait_vblank
   xor a                    ;; rLCDC = 0: pantalla apagada (lcd_on lo vuelve a configurar todo)
   ld [rLCDC], a
   ret

;;-----------------------------------------------------------------------------
;; lcd_on: enciende la pantalla con el fondo activo.
;; Tiles en $8000 (índices 0..255 sin signo) y tilemap en $9800.
;; Modifica: A
lcd_on::
   ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON
   ld [rLCDC], a
   ret

;;-----------------------------------------------------------------------------
;; memcpy: copia BC bytes desde HL hasta DE.
;; 📥 HL = origen, DE = destino, BC = número de bytes (debe ser > 0)
;; 📤 HL y DE quedan apuntando justo detrás de lo copiado
;; Modifica: A, F, BC, DE, HL
memcpy::
   ld a, [hl+]
   ld [de], a
   inc de
   dec bc
   ld a, b                  ;; dec bc no actualiza flags: comprobamos BC == 0 a mano.
   or c                     ;; B OR C solo da 0 si B y C valen 0 a la vez
   jr nz, memcpy
   ret
