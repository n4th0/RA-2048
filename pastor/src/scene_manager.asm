INCLUDE "constants.inc"

SECTION "Scene manager state", WRAM0
scene_id:: DS 1

SECTION "Scene manager CODE", ROM0


scene_manager_update::
   ld a, [scene_id]
   cp SCENE_TITLE
   jp z, scene_title_update
   cp SCENE_GAME
   jp z, scene_game_update
   jp scene_message_update  ;; SCENE_MESSAGE
