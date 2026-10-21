;;==============================================================
;; Challenge 6 · Sistema de autodestrucción (componente SELFDESTROY)
;; Una entidad con SELFDESTROY desaparece sola pasados unos frames.
;; La usan la espada y las nubes de humo.
;;==============================================================
INCLUDE "man/man_entity.inc"

SECTION "System: selfdestroy", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counts down ONE entity. When it reaches 0, it is removed.
;; Its data: the number of frames left, in E_LIFE.
;; ⚠️ Precondition: the entity has CMP_SELFDESTROY.
;; 📥 DE = entity
;; ❌ Modifies A, HL
sys_selfdestroy_one::
   ld   h, d                    ;; \ HL = &entity.LIFE (the frames left): the same page as
   ld   a, e                    ;; | the entity, the offset added to the low byte
   add  E_LIFE                  ;; | (one page: no carry)
   ld   l, a                    ;; /

   dec  [hl]                    ;; \ Frames left--
   ret  nz                      ;; / Not 0 yet: it goes on

   jp   man_entity_free         ;; Time is up: it is removed

;; The components an entity must have
;; to be processed by sys_selfdestroy_one
DEF REQUIRED_CMPs = CMP_SELFDESTROY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counts down ALL the entities that have SELFDESTROY.
;; ❌ Modifies A, BC, DE, HL
sys_selfdestroy_update::
   ld   hl, sys_selfdestroy_one
   ld   c, REQUIRED_CMPs        ;; Only the entities that have SELFDESTROY
   jp   man_entity_for_each_matching
