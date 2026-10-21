;;==============================================================
;; Challenge 6 · Escena del juego: constantes
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(GAME_INC)
DEF GAME_INC = 1

;; KIND (one bit per kind, so a mask can select several)
DEF KIND_PLAYER = %0001
DEF KIND_SWORD  = %0010
DEF KIND_ENEMY  = %0100
DEF KIND_PORTAL = %1000

;; The hero is always the first entity created after man_entity_init
DEF PLAYER_ENTITY EQUS "entity_array"
;;--------------------------------------------------------------
;; Game rules (all positions are WORLD pixels: 0-255, the map is 256 x 256)
;;--------------------------------------------------------------
DEF HEARTS_MAX    = 3       ;; hearts of the hero at the start of a game
DEF NUM_LEVELS    = 3       ;; levels in LevelTable (assets/levels/levels.asm)
DEF WALK_SPEED    = 1       ;; pixels per frame of anything that walks
DEF HURT_FRAMES   = 60      ;; frames the hero is immune after a hit (and flashes)
DEF SWORD_FRAMES  = 10      ;; frames the sword stays out
DEF POOF_FRAMES   = 12      ;; frames the cloud of a defeated enemy stays
DEF AI_THINK_MIN  = 24      ;; an enemy chooses a new way in 24 + (0..15) frames
DEF AI_THINK_MASK = %00001111
DEF AI_STILL_MASK = %11000000 ;; bits 7-6 at 0: stand still (1 time in 4)
DEF ANIM_STEP_MASK = %00000100   ;; bit 2 of TICK: the step changes every 4 frames
;; Two entities touch if they are closer than this (|dY| < HIT_H and |dX| < HIT_W).
;; Their images are 16 x 16: a smaller distance makes touching a bit more forgiving.
DEF SWORD_REACH   = 12      ;; the sword appears this far from the hero, where it faces
DEF HURT_FLASH_MASK = %00000100  ;; bit 2 of hurt_timer: palette changes every 4 frames
DEF HIT_H         = 12
DEF HIT_W         = 12
;; The part of an entity that the map stops: its FEET, a box of 8 x 8 pixels (the
;; size of a tile, so any tile it touches has one of its 4 corners inside). Offsets
;; from the top left corner of the entity: the box goes from FEET_LEFT to FEET_RIGHT,
;; and from FEET_TOP to FEET_BOTTOM
DEF FEET_LEFT     = 4
DEF FEET_RIGHT    = 11
DEF FEET_TOP      = 8
DEF FEET_BOTTOM   = 15

ENDC
