;;==============================================================
;; Challenge 5 · HUD: el marcador
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(HUD_INC)
DEF HUD_INC = 1

INCLUDE "engine/hardware.inc"

DEF HUD_SCORE_CELL = TILEMAP + 8          ;; row 0, column 8

ENDC
