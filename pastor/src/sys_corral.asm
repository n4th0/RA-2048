;;=============================================================================
;; sys_corral.asm — Sistema del corral: encierra ovejas y detecta la victoria
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Una oveja suelta que pisa suelo de corral pasa a TYPE_SHEEP_PENNED
;; (a partir de ahí la IA no la deja salir), descuenta sheep_left y suma
;; 10 puntos.
;; Cuando sheep_left llega a 0, game_won = 1.
;;=============================================================================
INCLUDE "constants.inc"

SECTION "Corral state", WRAM0
sheep_left:: DS 1            ;; ovejas que faltan por encerrar
game_won::   DS 1            ;; 1 cuando están todas dentro

SECTION "Corral system CODE", ROM0

;;-----------------------------------------------------------------------------
;; sys_corral_init: cuenta las ovejas del nivel.
;; Llamar después de crear las entidades.
sys_corral_init::
   xor a
   ld [sheep_left], a
   ld [game_won], a
   ld hl, count_loose_sheep
   jp man_entity_for_each

;;-----------------------------------------------------------------------------
;; count_loose_sheep: (para for_each) suma 1 a sheep_left si es oveja suelta.
;; 📥 DE = entidad
count_loose_sheep:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl]
   cp TYPE_SHEEP
   ret nz
   ld hl, sheep_left
   inc [hl]
   ret

;;-----------------------------------------------------------------------------
;; sys_corral_update: encierra las ovejas que han entrado y comprueba victoria.
;; Llamar después de sys_ai_update.
sys_corral_update::
   ld hl, sys_corral_one
   call man_entity_for_each
   ld a, [sheep_left]
   cp 0
   ret nz
   ld a, 1
   ld [game_won], a
   ret

;;-----------------------------------------------------------------------------
;; sys_corral_one: (para for_each) si una oveja suelta pisa corral, la encierra.
;; 📥 DE = entidad
sys_corral_one:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl+]              ;; HL -> E_Y
   cp TYPE_SHEEP
   ret nz
   ld b, [hl]
   inc l
   ld c, [hl]               ;; B, C = posición
   push de
   call level_tile_at
   pop de
   cp TILE_CORRAL
   ret nz

   ld h, d                  ;; encerrada
   ld a, E_TYPE
   add e
   ld l, a
   ld [hl], TYPE_SHEEP_PENNED
   ld hl, sheep_left
   dec [hl]
   ld hl, score + 4         ;; +10 puntos: sumar 1 al dígito de las decenas
   ld a, 1
   jp score_add_digit       ;; (también marca hud_dirty)
