;;==============================================================
;; Challenge 6 · Render: la Shadow OAM
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(RENDER_INC)
DEF RENDER_INC = 1

INCLUDE "man/man_entity.inc"
INCLUDE "engine/hardware.inc"

DEF SHADOW_OAM_SIZE = MAX_ENTITIES * SPRITES_PER_ENTITY * 4   ;; 96 bytes: 2 sprites of 4 bytes per entity

ENDC
