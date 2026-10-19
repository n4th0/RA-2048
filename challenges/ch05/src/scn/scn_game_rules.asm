;;==============================================================
;; Challenge 5 · Reglas del juego
;; Qué pasa tras una colisión. Los sistemas no las conocen: las llama
;; game_handle_collisions. Ya hechas, no hay que modificarlas.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game rules", ROM0

;;--------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Has the ship disappeared? When the ship crashes, it becomes an explosion; when
;; the explosion ends, its entity is freed (CMP = 0).
;; ⫷▬ Z if the ship is gone
;; ❌ Modifies A
is_ship_gone::
   INCBIN "bin/is_ship_gone.bin"          ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 12: `game_handle_collisions`
;; La implementas TÚ, en src/ej12.asm (etiqueta `ej12::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `game_handle_collisions` y no necesita saber dónde está tu código.
game_handle_collisions::
   jp   go_ej12              ;; Salta al ejercicio 12 (ver main.asm)
   ds   46, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates a bonus item from BonusTemplate. It falls straight down.
;; 📥 D = Y, E = X
;; ❌ Modifies A, BC, HL. Does NOT modify DE
bonus_spawn::
   INCBIN "bin/bonus_spawn.bin"           ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The player shoots when A has just been pressed, as long as the ship still obeys
;; the player (INPUT): an exploding ship does not shoot.
;; ❌ May modify A, BC, DE, HL
game_handle_shooting::
   INCBIN "bin/game_handle_shooting.bin"  ;; Rutina dada, en binario (15 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The player shoots: the shot appears one sprite above the ship.
;; Where it appears is a rule of the game. The system (sys_shot_spawn) creates it,
;; and checks that there is only ONE shot. The game never touches shot_entity.
;; ❌ May modify A, BC, DE, HL
shot_spawn::
   INCBIN "bin/shot_spawn.bin"            ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates an explosion that lasts EXPLOSION_FRAMES frames.
;; If there is no free entity, it does nothing.
;; 📥 D = Y, E = X
;; ❌ Modifies A, BC, HL. Does NOT modify DE
explosion_spawn::
   INCBIN "bin/explosion_spawn.bin"       ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The shot hit asteroids (which sys_collision_update already removed):
;; the player scores 1 point per asteroid, an explosion appears where the
;; shot is, the shot disappears and, sometimes (1 time in 4), a bonus item
;; appears there too.
;; 📥 A = number of asteroids hit
;; ❌ Modifies A, BC, DE, HL
game_enemy_hit::
   INCBIN "bin/game_enemy_hit.bin"        ;; Rutina dada, en binario (32 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The ship crashed. It does not disappear: it BECOMES an explosion, by
;; changing its components. It loses INPUT (it does not obey the player),
;; PHYSICS (it does not move) and COLLIDER (nothing collides with it), and
;; it gets SELFDESTROY. The game goes on until the explosion removes the
;; entity: then scene_game_update sees that the ship is gone.
;; ❌ Modifies A
game_ship_destroyed::
   INCBIN "bin/game_ship_destroyed.bin"   ;; Rutina dada, en binario (20 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The shot hit a bonus item (which sys_collision_update already removed): the
;; shot is lost too, and there are no points.
;; ❌ Modifies A, DE
game_bonus_shot::
   INCBIN "bin/game_bonus_shot.bin"       ;; Rutina dada, en binario (3 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The ship caught a bonus item.
;; ❌ Modifies A, HL
game_bonus_taken::
   INCBIN "bin/game_bonus_taken.bin"      ;; Rutina dada, en binario (5 bytes)
