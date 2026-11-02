;;=============================================================================
;; main.asm — Punto de entrada y bucle principal de Pastor
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Entry point", ROM0[$150]

main::
   di                       ;; sin interrupciones: sincronizamos leyendo rLY

   ;;--- Inicialización del hardware (una sola vez) ---
   call lcd_off

   ld hl, tiles             ;; tiles propios -> $8000
   ld de, _VRAM8000
   ld bc, tiles_end - tiles
   call memcpy

   ld a, %11100100          ;; paleta: 0 blanco, 1 gris claro, 2 gris oscuro, 3 negro
   ld [rBGP], a
   call sfx_init
   xor a                    ;; scroll a 0: no confiamos en lo que deje la boot ROM
   ld [rSCY], a
   ld [rSCX], a
   ld [joypad_dpad], a      ;; la WRAM arranca con basura (sesión 03.1)
   ld [joypad_buttons], a
   ld [joypad_pressed], a

   call record_load
   call scene_title_enter

   ;;--- Bucle principal: un frame de la escena activa por VBLANK ---
.mainloop:
   call wait_vblank
   call scene_manager_update
   jr .mainloop
