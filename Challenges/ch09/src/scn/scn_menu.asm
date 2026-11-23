;;==============================================================
;; Challenge 5 · Escena: menú
;; Título y botón Start. Cuando se pulsa START, empieza el juego.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"

SECTION "Scene: menu", ROM0

;; Each scene: DW init, update    (see scene_change)
scene_menu::     DW scene_menu_init, scene_menu_update

txt_title:       DB "CHASTEROIDS", TEXT_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu scene: title and the Start button. The screen is off.
;; The menu has no entities: it starts with no sprites (the ones of a previous game
;; are hidden), and then it shows the Start button.
scene_menu_init::
   INCBIN "bin/scene_menu_init.bin"       ;; Rutina dada, en binario (19 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 11 (a): `scene_menu_update`
;; La implementas TÚ, en src/ej11.asm (etiqueta `ej11a::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `scene_menu_update` y no necesita saber dónde está tu código.
scene_menu_update::
   jp   go_ej11a             ;; Salta al ejercicio 11 (ver main.asm)
   ds   9, $00              ;; Relleno: las demás rutinas conservan su dirección
