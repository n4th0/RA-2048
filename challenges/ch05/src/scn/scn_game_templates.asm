;;==============================================================
;; Challenge 5 · Plantillas de entidades del juego
;;
;; Cómo EMPIEZA cada tipo de entidad, como datos en la ROM. Para crear una,
;; se reserva una entidad y se copia su plantilla (man_entity_create).
;; Después solo se cambian los campos que dependen de la situación
;; (la posición del disparo, la columna de un asteroide...).
;;
;; Cada plantilla son SIZEOF_ENTITY bytes, en el orden de la estructura:
;;                CMP, Y, X, TILE, ATTR, VY, VX, KIND
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game: entity templates", ROM0

;; The player's ship. It can be moved by the player (INPUT) and by the physics.
ShipTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT
   DB SHIP_Y, SHIP_X_START, TILE_SHIP, 0
   DB 0, 0
   DB KIND_SHIP
ASSERT @ - ShipTemplate == SIZEOF_ENTITY

;; THE shot. Y and X: they depend on the ship. It is an entity like any other: it goes up with PHYSICS.
ShotTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER
   DB 0, 0, TILE_SHOT, 0
   DB -SHOT_SPEED, 0
   DB KIND_SHOT
ASSERT @ - ShotTemplate == SIZEOF_ENTITY

;; An asteroid. It starts above the screen (Y = 0). X, TILE, ATTR, VY and VX: random.
AsteroidTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER
   DB 0, 0, TILE_ASTEROID_A, 0
   DB 1, 0
   DB KIND_ENEMY
ASSERT @ - AsteroidTemplate == SIZEOF_ENTITY

;; A bonus item. It falls straight down. Y and X: where the shot hit.
BonusTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER
   DB 0, 0, TILE_BONUS, 0
   DB 1, 0
   DB KIND_BONUS
ASSERT @ - BonusTemplate == SIZEOF_ENTITY

;; An explosion. It has no COLLIDER and no PHYSICS. Y and X: where it happens.
;; Its last byte (the KIND of the entities with COLLIDER) is its countdown.
ExplosionTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_SELFDESTROY
   DB 0, 0, TILE_EXPLOSION, 0
   DB 0, 0
   DB EXPLOSION_FRAMES
ASSERT @ - ExplosionTemplate == SIZEOF_ENTITY
