;;==============================================================
;; Challenge 5 · Escena: el juego
;; Su init y su update. El update solo decide el ORDEN de los sistemas (sys/).
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Scene: game", ROM0

;; Each scene: DW init, update    (see scene_change)
scene_game::     DW scene_game_init, scene_game_update

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game scene: empty field, the HUD, the systems at their start, and the ship.
;; Each module initializes ITS OWN state (xxx_init): the scene does not touch it.
;; The screen is off.
scene_game_init::
   INCBIN "bin/scene_game_init.bin"       ;; Rutina dada, en binario (31 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game scene, every frame. First, the collisions; then, everything moves.
;; This way the collisions are checked with the positions that have just
;; been DRAWN, so the player sees the shot touch the asteroid (or the
;; asteroid touch the ship) before anything happens.
;;
;;  0. If the ship is gone (is_ship_gone: Z), it has finished exploding:
;;     go to the game over scene (scene_gameover).
;;     (This must be the first thing: nothing can have taken that slot yet.)
;;  1. game_handle_collisions: all the collisions of the game and what they cause.
;;  2. sys_input_update (sets VX from the D-pad), game_handle_shooting (A shoots),
;;     sys_physics_update (it moves EVERYTHING: the ship, the asteroids and the shot),
;;     sys_shot_update (the physics may have freed the shot: it forgets it),
;;     sys_spawn_update (after the movement: a new asteroid appears where it is
;;     created) and sys_selfdestroy_update.
;;  3. sys_prerender_update: prepares the sprites of how everything has ended
;;     up. The main loop copies them to the OAM in VBLANK.
scene_game_update::
   INCBIN "bin/scene_game_update.bin"     ;; Rutina dada, en binario (36 bytes)
