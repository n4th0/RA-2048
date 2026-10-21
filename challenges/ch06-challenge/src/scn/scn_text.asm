;;==============================================================
;; Challenge 6 · Pantallas de texto
;; Lo que tienen en común las escenas que son solo texto (menú, game over, victoria):
;; no hay mundo, ni entidades, ni HUD.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

SECTION "Scenes: text screens", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Starts a scene that is only text: no entities, no sprites, a blank background,
;; no HUD and the camera at the corner. The scene writes its texts after it.
;; An entity of the game that was still there would be drawn again by the pre-render.
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, DE, HL
scene_text_start::
   call man_entity_init         ;; \ No entities
   call oam_clear               ;; | No sprites
   call bg_clear                ;; | A blank background
   call hud_hide                ;; / No HUD

   call sys_camera_init         ;; \ The camera at the corner,
   jp   sys_render_scroll       ;; / and the background scrolled to it
