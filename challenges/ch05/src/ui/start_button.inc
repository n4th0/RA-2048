;;==============================================================
;; Challenge 5 · Botón Start
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(START_BUTTON_INC)
DEF START_BUTTON_INC = 1

INCLUDE "engine/hardware.inc"

DEF START_BUTTON_OAM  = OAM_START            ;; OAM slots 0-7
DEF START_BUTTON_SIZE = 8 * 4

ENDC
