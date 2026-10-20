;;=============================================================================
;; sys_input.asm — Sistema de control: mueve al pastor con la cruceta
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Mantener una dirección mueve una casilla cada SHEPHERD_STEP_FRAMES frames.
;; El primer paso es inmediato: el cooldown solo cuenta tras haber andado.
;; Si se pulsan varias direcciones a la vez gana una (derecha, izquierda,
;; arriba, abajo): en una cuadrícula no hay diagonales.
;;=============================================================================
INCLUDE "constants.inc"

SECTION "Input system CODE", ROM0

;;-----------------------------------------------------------------------------
;; sys_input_update: aplica el mando a las entidades controlables.
;; Llamar después de joypad_read.
sys_input_update::
   ld hl, sys_input_one
   jp man_entity_for_each

;;-----------------------------------------------------------------------------
;; sys_input_one: (para for_each) mueve la entidad si es el pastor.
;; 📥 DE = entidad
sys_input_one:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl]
   cp TYPE_SHEPHERD
   ret nz

   ;;--- Cooldown: si aún no toca dar un paso, solo se descuenta ---
   ld a, E_COOLDOWN
   add e
   ld l, a
   ld a, [hl]
   cp 0
   jr z, .ready
   dec [hl]
   ret

.ready:
   ld a, E_Y                ;; B, C = posición actual
   add e
   ld l, a
   ld b, [hl]
   inc l
   ld c, [hl]

   ld a, [joypad_dpad]      ;; B, C = casilla destino según la dirección
   bit PAD_RIGHT, a
   jr nz, .right
   bit PAD_LEFT, a
   jr nz, .left
   bit PAD_UP, a
   jr nz, .up
   bit PAD_DOWN, a
   ret z                    ;; ninguna dirección: quieto
   inc b
   jr .try_move
.right:
   inc c
   jr .try_move
.left:
   dec c
   jr .try_move
.up:
   dec b

.try_move:
   push de
   push bc
   call level_is_blocked
   pop bc
   pop de
   ret c                    ;; valla u otra entidad: no se mueve

   ld h, d                  ;; HL = &E_Y: guardamos la posición nueva
   ld a, E_Y
   add e
   ld l, a
   ld [hl], b
   inc l
   ld [hl], c

   ld a, E_COOLDOWN
   add e
   ld l, a
   ld [hl], SHEPHERD_STEP_FRAMES - 1   ;; -1: el frame del paso también cuenta
   ret
