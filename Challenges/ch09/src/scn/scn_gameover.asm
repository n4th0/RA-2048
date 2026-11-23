;;==============================================================
;; Challenge 5 · Escena: game over
;; Se dibuja ENCIMA del último fotograma del juego: no borra el fondo (con el
;; marcador) ni las entidades, para que se vea cómo ha terminado.
;; Esta escena no actualiza nada del juego: solo espera START. Los sprites
;; siguen ahí porque nadie los toca: la OAM conserva lo último que se copió.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"

SECTION "Scene: game over", ROM0

scene_gameover:: DW scene_gameover_init, scene_gameover_update

txt_game_over:   DB "GAME OVER", TEXT_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game over scene. It is drawn ON TOP of the last frame of the game: neither the
;; background (with the score) nor the entities are erased, so you can see
;; how it ended. It only adds the text and the Start button. The screen is off.
;; The scene does not update anything of the game: it only waits for START.
scene_gameover_init::
   INCBIN "bin/scene_gameover_init.bin"   ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 11 (b): `scene_gameover_update`
;; La implementas TÚ, en src/ej11.asm (etiqueta `ej11b::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `scene_gameover_update` y no necesita saber dónde está tu código.
scene_gameover_update::
   jp   go_ej11b             ;; Salta al ejercicio 11 (ver main.asm)
   ds   19, $00              ;; Relleno: las demás rutinas conservan su dirección
