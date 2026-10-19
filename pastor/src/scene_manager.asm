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

;; Rutina update de cada escena, en el orden de los SCENE_*
scene_update_table:
   dw scene_title_update
   dw scene_game_update
   dw scene_message_update
scene_update_table_end:
ASSERT scene_update_table_end - scene_update_table == 2 * (SCENE_MESSAGE + 1), "falta una escena en la tabla"

;;-----------------------------------------------------------------------------
;; scene_manager_update: ejecuta un frame de la escena activa.
;; Llamar una vez por frame, justo después de wait_vblank.
scene_manager_update::
   ld a, [scene_id]
   add a                    ;; 2 bytes por entrada
   ld hl, scene_update_table
   add l
   ld l, a
   adc h
   sub l
   ld h, a
   ld a, [hl+]
   ld h, [hl]
   ld l, a                  ;; HL = rutina de la escena
   jp hl                    ;; tail-call: su ret vuelve al bucle principal
