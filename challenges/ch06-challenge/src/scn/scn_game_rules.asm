;;==============================================================
;; Challenge 6 · Reglas del juego
;; Qué pasa cuando algo ocurre: un enemigo derrotado, un golpe al héroe, un nivel
;; terminado. Los sistemas no las conocen: las llama game_handle_collisions y
;; game_handle_attack. Aquí también está el ESTADO de la partida (nivel, corazones,
;; enemigos que quedan), que es PRIVADO de este fichero: los demás lo piden con game_get_*.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

SECTION "Game data", WRAM0
level_current::   DS 1                 ;; the level that is being played (0 is the first)
enemies_left::    DS 1                 ;; enemies that are still alive in this level
player_hearts:   DS 1                 ;; hearts the hero has left
hurt_timer:      DS 1                 ;; frames the hero is still immune after a hit (0 = vulnerable)

SECTION "Game rules", ROM0

;; Where the sword appears, relative to the hero, and how it is drawn, for each direction
;; (DIR_DOWN, DIR_UP, DIR_LEFT, DIR_RIGHT). Each entry is 4 bytes: dY, dX, TILE, ATTR.
;; The sword has 2 images (vertical and horizontal): flips make the other 2 directions.
SwordInfo:
   DB  SWORD_REACH,  0,            TILE_SWORD,                    0            ;; DIR_DOWN
   DB -SWORD_REACH,  0,            TILE_SWORD,                    ATTR_YFLIP   ;; DIR_UP
   DB  0,           -SWORD_REACH,  TILE_SWORD + TILES_PER_IMAGE,  ATTR_XFLIP   ;; DIR_LEFT
   DB  0,            SWORD_REACH,  TILE_SWORD + TILES_PER_IMAGE,  0            ;; DIR_RIGHT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A new game: the first level and all the hearts.
;; ❌ Modifies A
game_new::
   INCBIN "bin/game_new.bin"              ;; Rutina dada, en binario (10 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The state of the game, for whoever shows it (the HUD). It is read-only: only
;; this file changes it.
;; ⫷▬ A = the level that is being played (0 is the first) / the enemies that are
;;       alive in this level / the hearts the hero has left
;; ❌ Modifies A
game_get_level::
   INCBIN "bin/game_get_level.bin"        ;; Rutina dada, en binario (4 bytes)

game_get_enemies::
   INCBIN "bin/game_get_enemies.bin"      ;; Rutina dada, en binario (4 bytes)

game_get_hearts::
   INCBIN "bin/game_get_hearts.bin"       ;; Rutina dada, en binario (4 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The data of the level that is being played (see assets/levels/levels.asm).
;; ⫷▬ HL = the address of its data
;; ❌ Modifies A, DE, HL
level_get::
   INCBIN "bin/level_get.bin"             ;; Rutina dada, en binario (15 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates an entity from a template in a TILE of the map. The map is made of tiles of
;; 8 x 8 pixels, and positions of entities are in pixels: a position in tiles is
;; multiplied by 8 (three times * 2).
;; 📥 HL = template, C = column (tile X), B = row (tile Y)
;; ⫷▬ Z, HL = the new entity
;;    NZ, there is no free entity
;; ❌ Modifies A, BC, HL. Does NOT modify DE
game_spawn_at::
   INCBIN "bin/game_spawn_at.bin"         ;; Rutina dada, en binario (21 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads the level that is being played: draws its map and creates the hero and the
;; enemies (game_enemies_spawn). The hero must be the FIRST entity created (it is PLAYER_ENTITY).
;; ⚠️ The screen must be OFF, and the entities empty (man_entity_init)
;; ❌ Modifies A, BC, DE, HL
game_level_load::
   INCBIN "bin/game_level_load.bin"       ;; Rutina dada, en binario (41 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 06: `game_enemies_spawn`
;; La implementas TÚ, en src/ej06.asm (etiqueta `ej06::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `game_enemies_spawn` y no necesita saber dónde está tu código.
game_enemies_spawn::
   jp   go_ej06              ;; Salta al ejercicio 06 (ver main.asm)
   ds   23, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Has the hero disappeared? When the hero dies, it becomes a cloud of smoke; when the
;; cloud ends, its entity is freed (CMP = 0).
;; ⫷▬ Z if the hero is gone
;; ❌ Modifies A
is_player_gone::
   INCBIN "bin/is_player_gone.bin"        ;; Rutina dada, en binario (5 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Creates a cloud of smoke that lasts POOF_FRAMES frames.
;; If there is no free entity, it does nothing.
;; 📥 D = Y, E = X
;; ❌ Modifies A, BC, HL. Does NOT modify DE
poof_spawn::
   INCBIN "bin/poof_spawn.bin"            ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 07: `portal_spawn`
;; La implementas TÚ, en src/ej07.asm (etiqueta `ej07::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `portal_spawn` y no necesita saber dónde está tu código.
portal_spawn::
   jp   go_ej07              ;; Salta al ejercicio 07 (ver main.asm)
   ds   22, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The sword touched an enemy: a sound effect, a cloud of smoke appears where the enemy
;; was, and the enemy is removed. When it was the last one, the portal opens.
;; 📥 DE = the enemy
;; ❌ Modifies A, BC, DE, HL
game_enemy_defeated::
   INCBIN "bin/game_enemy_defeated.bin"   ;; Rutina dada, en binario (37 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; An enemy touched the hero: a sound effect, it loses a heart, and is immune for HURT_FRAMES
;; frames (enemies cannot hurt it again until then). With no hearts, it dies.
;; ❌ Modifies A, HL
game_player_hurt::
   INCBIN "bin/game_player_hurt.bin"      ;; Rutina dada, en binario (25 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The hero dies. It does not disappear: it BECOMES a cloud of smoke, by changing its
;; components. It loses INPUT (it does not obey the player), PHYSICS (it does not move),
;; COLLIDER (nothing collides with it) and ANIMATION, and it gets SELFDESTROY. The game
;; goes on until the cloud removes the entity: then scene_game_update sees that the hero is gone.
;; ❌ Modifies A
game_player_destroyed::
   INCBIN "bin/game_player_destroyed.bin" ;; Rutina dada, en binario (24 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Starts the song of the level that is being played, from its beginning.
;; ❌ Modifies A, BC, DE, HL
game_level_song::
   INCBIN "bin/game_level_song.bin"       ;; Rutina dada, en binario (13 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The hero reached the portal: the next level, or the end of the game.
;; ❌ Modifies A, BC, DE, HL
game_level_done::
   INCBIN "bin/game_level_done.bin"       ;; Rutina dada, en binario (18 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The immunity of the hero after a hit: it counts down, and while it lasts the hero
;; flashes (its sprites use the palette 1, which is the other way round, every few frames).
;; ❌ Modifies A, B
game_hurt_update::
   INCBIN "bin/game_hurt_update.bin"      ;; Rutina dada, en binario (24 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All the collisions of the game, and what they cause. The system
;; (sys_collision_update) only checks ONE probe against all the entities:
;; the rules of the game say who is the probe, who it collides with and what happens.
;;  1. The sword (if there is one, sys_sword_get) against the enemies: the first one it
;;     touches is defeated (game_enemy_defeated).
;;  2. The hero against the enemies, unless it is immune: it is hurt (game_player_hurt).
;;  3. The hero against the portal: the level is done (game_level_done). It goes last:
;;     the game changes scene and everything after it would happen in the new level.
;; ⚠️ sys_collision_update returns Z (none) / NZ (DE = the entity hit)
;; ❌ May modify A, BC, DE, HL
game_handle_collisions::
   INCBIN "bin/game_handle_collisions.bin" ;; Rutina dada, en binario (42 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The hero attacks when A has just been pressed, as long as it still obeys the
;; player (INPUT): a dead hero does not attack. The sword appears in front of it, where
;; SwordInfo says for the direction it faces, with its sound effect. There is only ONE sword.
;; ❌ May modify A, BC, DE, HL
game_handle_attack::
   INCBIN "bin/game_handle_attack.bin"    ;; Rutina dada, en binario (60 bytes)
