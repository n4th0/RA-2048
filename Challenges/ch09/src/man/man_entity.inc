;;==============================================================
;; Challenge 5 · Gestor de entidades: estructura y componentes
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(MAN_ENTITY_INC)
DEF MAN_ENTITY_INC = 1
;;--------------------------------------------------------------
;; Entities: array of MAX_ENTITIES entities of SIZEOF_ENTITY bytes
;;--------------------------------------------------------------
DEF MAX_ENTITIES = 8
RSRESET
DEF E_CMP         RB 1           ;; 0  Which components the entity has (bitflags)
DEF E_SPRITE      RB 1           ;; SPRITE data (offset): same OAM entry 4 bytes
DEF E_Y =     E_SPRITE           ;; 1  ┐ E_Y = E_SPRITE (same byte)
DEF E_X           RB 1           ;; 2  │ SPRITE bytes can be copied as they are.
DEF E_TILE        RB 1           ;; 3  │ Y and X are OAM coordinates (screen + 16, + 8)
DEF E_ATTR        RB 1           ;; 4  ┘
DEF E_VY          RB 1           ;; 5  ┐ PHYSICS: velocity (signed) in pixels per frame
DEF E_VX          RB 1           ;; 6  ┘
DEF E_KIND        RB 1           ;; 7  COLLIDER: what kind of thing this entity is
                                 ;;    SELFDESTROY: frames left (shared byte: an entity
                                 ;;    with it has no COLLIDER. Avoids a 9th byte)
DEF SIZEOF_ENTITY RB 0           ;; = 8
DEF ENTITY_ARRAY_SIZE = MAX_ENTITIES * SIZEOF_ENTITY

;; Bits of CMP. CMP = 0 → the entity is FREE.
;; Changing the bits while the game runs changes what the entity does
DEF CMP_SPRITE_BIT      = 0
DEF CMP_PHYSICS_BIT     = 1
DEF CMP_COLLIDER_BIT    = 2
DEF CMP_SELFDESTROY_BIT = 3
DEF CMP_INPUT_BIT       = 4
DEF CMP_ALIVE_BIT       = 7
;; Bit Masks for CMPs
DEF CMP_SPRITE          = 1 << CMP_SPRITE_BIT
DEF CMP_PHYSICS         = 1 << CMP_PHYSICS_BIT
DEF CMP_COLLIDER        = 1 << CMP_COLLIDER_BIT
DEF CMP_SELFDESTROY     = 1 << CMP_SELFDESTROY_BIT
DEF CMP_INPUT           = 1 << CMP_INPUT_BIT ;; Controlled by the player. It has no data
DEF CMP_ALIVE           = 1 << CMP_ALIVE_BIT

ENDC
