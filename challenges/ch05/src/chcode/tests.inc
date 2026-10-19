;;==============================================================
;; Challenge 5 · Auxiliares de las pruebas
;;   ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/text.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "ui/hud.inc"
INCLUDE "scn/scn_game.inc"

MACRO tst_reset_extra
   ld   a, SHOT_NONE
   ld   [shot_entity], a
ENDM

;;##############################################################
;;  AUXILIARES DE LAS PRUEBAS (no hace falta leerlos)
;;##############################################################
SECTION "Test vars", WRAM0[$C800]
tst_log::      DS 16                 ;; the callback of the tests writes here
tst_n::        DS 1                  ;; how many entries the log has

SECTION "Test helpers", ROM0

;; HL: dst · B: count · A: value
tst_memset::
   ld   [hl+], a
   dec  b
   jr   nz, tst_memset
   ret

;; HL: src · DE: dst · B: count
tst_memcpy::
   ld   a, [hl+]
   ld   [de], a
   inc  de
   dec  b
   jr   nz, tst_memcpy
   ret

;; Every case starts from the same state: the data and the entities (C000-C1FF) at 0
tst_reset::
   ld   hl, $C000
   xor  a
   ld   b, 0
   call tst_memset
   ld   hl, $C100
   xor  a
   ld   b, 0
   call tst_memset
   ld   hl, tst_log
   xor  a
   ld   b, 17
   call tst_memset
   ld   a, $A5                       ;; rng_state: never 0
   ld   [rng_state], a
   ld   a, $5A
   ld   [rng_state + 1], a
   tst_reset_extra
   ret

;; Callback for the for_each tests: it logs the low byte of the entity (DE) and then
;; DESTROYS every register (the real routines may do it)
tst_cb_log::
   ld   hl, tst_n
   ld   a, [hl]
   inc  [hl]
   ld   hl, tst_log
   add  l
   ld   l, a
   ld   [hl], e
   ld   bc, $FFFF
   ld   de, $FFFF
   ld   hl, $0000
   ret

;; Same, but it logs B (the number of the entity that for_each gives)
tst_cb_log_b::
   ld   hl, tst_n
   ld   a, [hl]
   inc  [hl]
   ld   hl, tst_log
   add  l
   ld   l, a
   ld   [hl], b
   ld   bc, $FFFF
   ld   de, $FFFF
   ld   hl, $0000
   ret

;; HL: dst · B: count · A: first value → first, first+1, first+2...
tst_ramp::
   ld   [hl+], a
   inc  a
   dec  b
   jr   nz, tst_ramp
   ret

;; Every entity alive (only CMP_ALIVE)
tst_alive_all::
   ld   hl, entity_array
   ld   b, MAX_ENTITIES
.next
   ld   [hl], CMP_ALIVE
   ld   a, l
   add  SIZEOF_ENTITY
   ld   l, a
   dec  b
   jr   nz, .next
   ret

;; tst_fill address, count, value
MACRO tst_fill
   ld   hl, \1
   ld   a, \3
   ld   b, \2
   call tst_memset
ENDM

;; tst_ramp_at address, count, first
MACRO tst_ramp_at
   ld   hl, \1
   ld   a, \3
   ld   b, \2
   call tst_ramp
ENDM

;; tst_ent slot, CMP, Y, X, TILE, ATTR, VY, VX, KIND
MACRO tst_ent
   ld   hl, entity_array + (\1) * SIZEOF_ENTITY
   ld   a, \2
   ld   [hl+], a
   ld   a, \3
   ld   [hl+], a
   ld   a, \4
   ld   [hl+], a
   ld   a, \5
   ld   [hl+], a
   ld   a, \6
   ld   [hl+], a
   ld   a, \7
   ld   [hl+], a
   ld   a, \8
   ld   [hl+], a
   ld   a, \9
   ld   [hl], a
ENDM

;; tst_set8 address, value
MACRO tst_set8
   ld   a, \2
   ld   [\1], a
ENDM

;; tst_set16 address, value  (little-endian)
MACRO tst_set16
   ld   a, LOW(\2)
   ld   [\1], a
   ld   a, HIGH(\2)
   ld   [\1 + 1], a
ENDM
