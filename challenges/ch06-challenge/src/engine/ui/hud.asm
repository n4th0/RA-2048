;;==============================================================
;; Challenge 6 · HUD: corazones, nivel y enemigos
;; Una franja en la window: se dibuja encima del background y no se mueve
;; con el scroll. El HUD solo MUESTRA: pide el estado del juego (corazones, nivel,
;; enemigos) con game_get_* y no lo cambia. Cuando algo cambia, el juego pide redibujarlo (hud_refresh).
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "HUD data", WRAM0
hud_dirty:       DS 1                 ;; 1 → the HUD must be redrawn

SECTION "HUD", ROM0

txt_level:       DB "NIVEL", TEXT_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the HUD: nothing to redraw.
;; ❌ Modifies A
hud_init::
   INCBIN "bin/hud_init.bin"              ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 05 (a): `hud_show`
;; La implementas TÚ, en src/ej05.asm (etiqueta `ej05a::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `hud_show` y no necesita saber dónde está tu código.
hud_show::
   jp   go_ej05a             ;; Salta al ejercicio 05 (ver main.asm)
   ds   6, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hides the window: it is moved below the screen.
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A
hud_hide::
   INCBIN "bin/hud_hide.bin"              ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The HUD has to be redrawn at the end of this frame.
;; ❌ Modifies A
hud_refresh::
   INCBIN "bin/hud_refresh.bin"           ;; Rutina dada, en binario (6 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 05 (b): `hud_draw_hearts`
;; La implementas TÚ, en src/ej05.asm (etiqueta `ej05b::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `hud_draw_hearts` y no necesita saber dónde está tu código.
hud_draw_hearts::
   jp   go_ej05b             ;; Salta al ejercicio 05 (ver main.asm)
   ds   17, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draws the HUD in the window: the hearts (full or empty), the number of the level
;; and how many enemies are left.
;; ⚠️ The screen must be OFF (or be in VBLANK)
;; ❌ Modifies A, BC, DE, HL
hud_draw::
   INCBIN "bin/hud_draw.bin"              ;; Rutina dada, en binario (51 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Redraws the HUD if something has changed.
;; It is called right after the sprites are copied to the OAM, still in VBLANK.
;; ❌ Modifies A, BC, DE, HL
hud_update::
   INCBIN "bin/hud_update.bin"            ;; Rutina dada, en binario (12 bytes)
