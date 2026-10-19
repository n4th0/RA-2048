;;==============================================================
;; Challenge 5 · Escena del juego: constantes
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(GAME_INC)
DEF GAME_INC = 1

;; KIND (one bit per kind, so a mask can select several)
DEF KIND_SHIP  = %0001
DEF KIND_SHOT  = %0010
DEF KIND_ENEMY = %0100
DEF KIND_BONUS = %1000

;; The ship is always the first entity created after man_entity_init
DEF SHIP_ENTITY EQUS "entity_array"
;;--------------------------------------------------------------
;; Game rules (all in OAM coordinates: screen y + 16, screen x + 8)
;;--------------------------------------------------------------
DEF SHIP_Y        = 144     ;; screen y = 128
DEF SHIP_X_START  = 84
DEF INPUT_SPEED   = 2       ;; pixels per frame of an entity with INPUT
DEF INPUT_X_MIN   = 8       ;; an entity with INPUT cannot go past these limits
DEF INPUT_X_MAX   = 160     ;; (sys_physics keeps it inside)
DEF SHOT_SPEED    = 4       ;; pixels per frame (the shot goes up: VY = -SHOT_SPEED)
DEF SHOT_NONE     = $FF     ;; shot_entity = SHOT_NONE → there is no shot
DEF ENTITY_OUT_Y  = 160     ;; Y from here on → off the bottom
DEF ENTITY_OUT_X  = 168     ;; X from here on → off the right
                            ;; (a coordinate that goes below 0 wraps to 255+)
DEF HIT_H         = 5       ;; two sprites overlap if |dY| < HIT_H
DEF HIT_W         = 7       ;; and |dX| < HIT_W
DEF EXPLOSION_FRAMES = 12   ;; frames an explosion stays on the screen
DEF DIAGONAL_VY    = 2      ;; diagonal asteroids always fall at this speed (VX = +/-1)
DEF DIAGONAL_SHIFT = SHIP_Y / DIAGONAL_VY  ;; so, from the top to the ship's row
                                           ;; they move this much sideways (72)
DEF DIAGONAL_SPLIT = INPUT_X_MIN + DIAGONAL_SHIFT ;; a target from here on:
                                                  ;; it comes from the left (80)
DEF SIDE_SPAWN_X_LEFT  = 0  ;; diagonals can also come in from the sides of the screen:
DEF SIDE_SPAWN_X_RIGHT = ENTITY_OUT_X - 1 ;; just outside (X=0→hidden, 167→one column)
DEF SIDE_SPAWN_MIN_Y   = 16 ;; from the top of the screen (OAM Y of the screen row 0)..
DEF SIDE_SPAWN_STEPS   = 37 ;; ..in steps of 2, down to half the screen (Y = 88)
DEF SPAWN_FIRST_FRAMES = 45
DEF SPAWN_MIN_FRAMES   = 30 ;; next asteroid in 30 + (0..31) frames
DEF POINTS_ENEMY  = 1       ;; points for an asteroid (one digit: 0-9)
DEF POINTS_BONUS  = 5       ;; points for a bonus item (one digit: 0-9)

ENDC
