;;==============================================================
;; Challenge 6 · Sistema de IA (componente AI)
;; Las entidades con AI deciden solas hacia dónde ir: cada cierto tiempo eligen
;; una dirección al azar (o quedarse quietas). Como el jugador con INPUT, solo
;; deciden: caminar lo hace sys_physics.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "System: ai", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AI system, for ONE entity: every so often, it chooses what to do next.
;; Its THINK counts the frames left before it chooses. When it reaches 0:
;;  - THINK = AI_THINK_MIN + a random number (0-15): the time until the next choice.
;;  - It chooses what to do with that same random number (sys_ai_choose).
;; ⚠️ Precondition: the entity has CMP_AI.
;; 📥 DE = entity
;; ❌ Modifies A, BC, HL
sys_ai_one::
   INCBIN "bin/sys_ai_one.bin"            ;; Rutina dada, en binario (22 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 08: `sys_ai_choose`
;; La implementas TÚ, en src/ej08.asm (etiqueta `ej08::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_ai_choose` y no necesita saber dónde está tu código.
sys_ai_choose::
   jp   go_ej08              ;; Salta al ejercicio 08 (ver main.asm)
   ds   12, $00              ;; Relleno: las demás rutinas conservan su dirección
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AI system, for ALL the entities that have AI.
;; ❌ Modifies A, BC, DE, HL
sys_ai_update::
   INCBIN "bin/sys_ai_update.bin"         ;; Rutina dada, en binario (8 bytes)
