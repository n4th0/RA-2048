;;==============================================================
;; Challenge 6 · Escena: el juego
;; Su init y su update. El update solo decide el ORDEN de los sistemas (sys/).
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Scene: game", ROM0

;; Each scene: DW init, update    (see scene_change)
scene_game::     DW scene_game_init, scene_game_update

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game scene: the level that is being played (game_level_load draws its map and creates
;; the hero and the enemies), the song of the level, the HUD, the systems at their start,
;; and the camera on the hero.
;; Each module initializes ITS OWN state (xxx_init): the scene does not touch it.
;; It is called for EVERY level: the game changes to this same scene for the next one.
;; The screen is off.
scene_game_init::
   call rng_seed                ;; The wait in the menu makes the seed different each time

   call man_entity_init         ;; \ Empty slate: no entities
   call oam_clear               ;; / and no sprites

   call sys_sword_init          ;; The systems start from scratch: no sword
   call sys_camera_init         ;; and the camera at the corner

   call game_level_load         ;; The map, the hero and the enemies of the level
   call game_level_song         ;; and its song, from the beginning

   ld   de, PLAYER_ENTITY       ;; \ The camera on the hero, and the scroll set before the
   call sys_camera_update       ;; | screen is on: the first frame is already the right one
   call sys_render_scroll       ;; /

   call hud_show                ;; \ The HUD: hearts, level and enemies
   jp   hud_draw                ;; / drawn (the screen is off)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Game scene, every frame. First, the collisions; then, everything moves.
;; This way the collisions are checked with the positions that have just
;; been DRAWN, so the player sees the sword touch the enemy (or the enemy
;; touch the hero) before anything happens.
;;
;;  0. If the hero is gone (is_player_gone: Z), it has finished dying:
;;     go to the game over scene (scene_gameover).
;;     (This must be the first thing: nothing can have taken that slot yet.)
;;  1. game_handle_collisions: all the collisions of the game and what they cause.
;;  2. game_handle_attack (A takes out the sword), sys_input_update and sys_ai_update
;;     (they decide where to walk: the hero from the D-pad, the enemies by themselves),
;;     sys_physics_update (it moves EVERYTHING that walks, with the map in its way),
;;     sys_animation_update (their images), sys_selfdestroy_update (the sword and the
;;     clouds go away) and sys_sword_update (the sword may have gone: it forgets it).
;;     game_hurt_update counts down the immunity of the hero.
;;  3. sys_camera_update puts the camera on the hero, and sys_prerender_update prepares
;;     the sprites of how everything has ended up. The main loop copies them to the OAM in VBLANK.
scene_game_update::
   call is_player_gone          ;; Z if the hero has gone
   jp   z, .game_over

   call game_handle_collisions  ;; 1. Collisions first, with what has been drawn

   call game_handle_attack      ;; 2. Everything moves
   call sys_input_update
   call sys_ai_update
   call sys_physics_update
   call sys_animation_update
   call sys_selfdestroy_update
   call sys_sword_update        ;; AFTER selfdestroy: it may have removed the sword
   call game_hurt_update

   ld   de, PLAYER_ENTITY       ;; 3. The camera on the hero, and prepare the sprites
   call sys_camera_update
   jp   sys_prerender_update

.game_over
   ld   hl, scene_gameover
   jp   scene_change
