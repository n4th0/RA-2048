;;==============================================================
;; Challenge 6 · Plantillas de entidades del juego
;;
;; Cómo EMPIEZA cada tipo de entidad, como datos en la ROM. Para crear una,
;; se reserva una entidad y se copia su plantilla (man_entity_create).
;; Después solo se cambian los campos que dependen de la situación
;; (la posición, el tile de la espada...).
;;
;; Cada plantilla son SIZEOF_ENTITY bytes, en el orden de la estructura:
;;      CMP, Y, X, TILE, ATTR, VY, VX, KIND, DIR, SHEET, TICK, LIFE, THINK, (3 reservados)
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Game: entity templates", ROM0

;; The hero. It obeys the player (INPUT), walks with the map in its way (PHYSICS),
;; collides with enemies and the portal (COLLIDER) and animates (ANIMATION).
;; Y and X: where the level starts it.
PlayerTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_INPUT | CMP_ANIMATION
   DB 0, 0, TILE_PLAYER, 0
   DB 0, 0
   DB KIND_PLAYER
   DB DIR_DOWN, TILE_PLAYER, 0, 0, 0
   DS 3, 0
ASSERT @ - PlayerTemplate == SIZEOF_ENTITY

;; THE sword. It does not move or animate: it is there for SWORD_FRAMES frames and goes away
;; by itself (SELFDESTROY). Y, X, TILE and ATTR: they depend on where the hero faces.
SwordTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_COLLIDER | CMP_SELFDESTROY
   DB 0, 0, TILE_SWORD, 0
   DB 0, 0
   DB KIND_SWORD
   DB DIR_DOWN, 0, 0, SWORD_FRAMES, 0
   DS 3, 0
ASSERT @ - SwordTemplate == SIZEOF_ENTITY

;; An enemy. It chooses where to go by itself (AI), walks with the map in its way (PHYSICS)
;; and animates. Y and X: where the level puts it. THINK = 1: it chooses at once.
EnemyTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_PHYSICS | CMP_COLLIDER | CMP_ANIMATION | CMP_AI
   DB 0, 0, TILE_ENEMY, 0
   DB 0, 0
   DB KIND_ENEMY
   DB DIR_DOWN, TILE_ENEMY, 0, 0, 1
   DS 3, 0
ASSERT @ - EnemyTemplate == SIZEOF_ENTITY

;; The portal that takes the hero to the next level. It is always animating (it has no PHYSICS).
;; Y and X: where the level puts it.
PortalTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_COLLIDER | CMP_ANIMATION
   DB 0, 0, TILE_PORTAL, 0
   DB 0, 0
   DB KIND_PORTAL
   DB DIR_DOWN, TILE_PORTAL, 0, 0, 0
   DS 3, 0
ASSERT @ - PortalTemplate == SIZEOF_ENTITY

;; A cloud of smoke: it appears where an enemy has been defeated and goes away by itself.
;; It has no COLLIDER (nothing collides with it) and no PHYSICS (it does not move).
;; Y and X: where it happens.
PoofTemplate::
   DB CMP_ALIVE | CMP_SPRITE | CMP_SELFDESTROY
   DB 0, 0, TILE_POOF, 0
   DB 0, 0
   DB 0
   DB DIR_DOWN, 0, 0, POOF_FRAMES, 0
   DS 3, 0
ASSERT @ - PoofTemplate == SIZEOF_ENTITY
