;;=============================================================================
;; scene_manager.asm — Llama cada frame a la escena activa
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Cada escena tiene una rutina "enter" (apaga la pantalla, la prepara, la
;; enciende y pone scene_id) y una "update" (un frame). Para cambiar de
;; escena, una update llama al enter de otra; el siguiente frame ya
;; ejecuta la update nueva.
;;=============================================================================
INCLUDE "constants.inc"

SECTION "Scene manager state", WRAM0
scene_id:: DS 1

SECTION "Scene manager CODE", ROM0

;;-----------------------------------------------------------------------------
;; scene_manager_update: ejecuta un frame de la escena activa.
;; Llamar una vez por frame, justo después de wait_vblank.
;; Los jp son tail-calls (sesión 05.2): el ret de la escena vuelve al bucle.
scene_manager_update::
   ld a, [scene_id]
   cp SCENE_TITLE
   jp z, scene_title_update
   cp SCENE_GAME
   jp z, scene_game_update
   jp scene_message_update  ;; SCENE_MESSAGE
