;;==============================================================
;; Challenge 6 · Auxiliares de las pruebas
;;   ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

;;##############################################################
;;  AUXILIARES DE LAS PRUEBAS (no hace falta leerlos)
;;##############################################################
SECTION "Test vars", WRAM0[$C800]
tst_log::      DS 16                 ;; the tests write here what they want to show
tst_data::     DS 32                 ;; data that a test needs in RAM

SECTION "Test helpers", ROM0

;; HL: dst · B: count · A: value
tst_memset::
   ld   [hl+], a
   dec  b
   jr   nz, tst_memset
   ret

;; HL: dst · B: count · A: first value → first, first+1, first+2...
tst_ramp::
   ld   [hl+], a
   inc  a
   dec  b
   jr   nz, tst_ramp
   ret

;; Every case starts from the same state: the entities and the data (C000-C0FF) and the shadow OAM at 0
tst_reset::
   ld   hl, $C000
   xor  a
   ld   b, 0
   call tst_memset
   ld   hl, shadow_oam
   xor  a
   ld   b, 160
   call tst_memset
   ld   hl, tst_log
   xor  a
   ld   b, 48
   call tst_memset
   ld   a, $A5                       ;; rng_state: never 0
   ld   [rng_state], a
   ld   a, $5A
   ld   [rng_state + 1], a
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
