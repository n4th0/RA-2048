;;=============================================================================
;; sys_ai.asm — Sistema de IA: las ovejas huyen del pastor
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Cada SHEEP_STEP_FRAMES frames, cada oveja decide:
;;  - Si el pastor está cerca (|dx| + |dy| <= SHEEP_SCARE_DISTANCE), da un paso
;;    alejándose por el eje en el que está más lejos. Si ese paso está
;;    bloqueado, prueba el otro eje; si ninguno vale, se queda quieta.
;;  - Si no, con probabilidad SHEEP_GRAZE_CHANCE/256 da un paso al azar.
;; Las ovejas encerradas hacen lo mismo pero solo pueden pisar suelo de corral.
;;=============================================================================
INCLUDE "constants.inc"

SECTION "AI state", WRAM0
ai_player_y:    DS 1
ai_player_x:    DS 1
ai_dy:          DS 1         ;; oveja - pastor, con signo
ai_dx:          DS 1
ai_entity_type: DS 1         ;; tipo de la oveja que se está procesando

SECTION "AI system CODE", ROM0

;;-----------------------------------------------------------------------------
;; sys_ai_update: localiza al pastor y aplica la IA a cada oveja.
;; Llamar después de sys_input_update (reaccionan en el mismo frame).
sys_ai_update::
   ld hl, ai_find_player
   call man_entity_for_each
   ld hl, sys_ai_one
   jp man_entity_for_each

;;-----------------------------------------------------------------------------
;; ai_find_player: (para for_each) si es el pastor, guarda su posición.
;; 📥 DE = entidad
ai_find_player:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl+]              ;; A = tipo, HL -> E_Y
   cp TYPE_SHEPHERD
   ret nz
   ld a, [hl+]
   ld [ai_player_y], a
   ld a, [hl]
   ld [ai_player_x], a
   ret

;;-----------------------------------------------------------------------------
;; sys_ai_one: (para for_each) decide el paso de una oveja.
;; 📥 DE = entidad
sys_ai_one:
   ld h, d
   ld a, E_TYPE
   add e
   ld l, a
   ld a, [hl]
   cp TYPE_SHEEP
   jr z, .is_sheep
   cp TYPE_SHEEP_PENNED
   ret nz
.is_sheep:
   ld [ai_entity_type], a

   ;;--- Solo decide cada SHEEP_STEP_FRAMES frames ---
   ld a, E_COOLDOWN
   add e
   ld l, a
   ld a, [hl]
   or a
   jr z, .ready
   dec [hl]
   ret
.ready:
   ld [hl], SHEEP_STEP_FRAMES - 1   ;; se mueva o no: así el azar va a ritmo fijo

   ld a, E_Y                ;; B, C = posición de la oveja
   add e
   ld l, a
   ld b, [hl]
   inc l
   ld c, [hl]

   ;;--- dy, dx = oveja - pastor ---
   ld a, [ai_player_y]
   cpl
   inc a                    ;; A = -pastor.y
   add b
   ld [ai_dy], a
   ld a, [ai_player_x]
   cpl
   inc a
   add c
   ld [ai_dx], a

   ;;--- ¿Está el pastor cerca? ---
   ld a, [ai_dy]
   call abs_a
   ld h, a                  ;; H = |dy|
   ld a, [ai_dx]
   call abs_a
   ld l, a                  ;; L = |dx|
   add h                    ;; A = distancia (como mucho 19 + 17: sin desbordar)
   cp SHEEP_SCARE_DISTANCE + 1
   jr nc, .graze

   ld a, h                  ;; huir: primero por el eje más lejano
   cp l
   jr c, .horizontal_first  ;; |dy| < |dx|
   call ai_flee_vertical
   ret nc                   ;; se movió
   jp ai_flee_horizontal
.horizontal_first:
   call ai_flee_horizontal
   ret nc
   jp ai_flee_vertical

.graze:
   call rng_next
   cp SHEEP_GRAZE_CHANCE
   ret nc                   ;; la mayoría de las veces se queda quieta
   call rng_next
   and 3                    ;; dirección al azar
   add a                    ;; 2 bytes por dirección
   ld hl, directions
   add l
   ld l, a
   adc h
   sub l
   ld h, a                  ;; HL = &directions[n]
   ld a, [hl+]
   ld l, [hl]               ;; L = dx
   ld h, a                  ;; H = dy
   jp ai_try_offset

;; (dy, dx) de las 4 direcciones
directions:
   db -1,  0
   db  1,  0
   db  0, -1
   db  0,  1

;;-----------------------------------------------------------------------------
;; ai_flee_vertical / ai_flee_horizontal: un paso alejándose en ese eje.
;; Si oveja y pastor están en la misma fila/columna no hay "lejos": se prueba
;; un sentido al azar y, si está bloqueado, el contrario.
;; 📥 DE = entidad, B, C = posición actual
;; 📤 carry a 0 si se movió, a 1 si no
ai_flee_vertical:
   ld l, 0
   ld a, [ai_dy]
   or a
   jr z, .either
   ld h, 1                  ;; dy > 0: está debajo del pastor, baja
   bit 7, a
   jr z, ai_try_offset
   ld h, -1                 ;; dy < 0: sube
   jr ai_try_offset
.either:
   call rng_sign
   ld h, a
   push hl
   call ai_try_offset
   pop hl
   ret nc
   ld a, h                  ;; sentido contrario
   cpl
   inc a
   ld h, a
   jr ai_try_offset

ai_flee_horizontal:
   ld h, 0
   ld a, [ai_dx]
   or a
   jr z, .either
   ld l, 1                  ;; dx > 0: está a la derecha del pastor
   bit 7, a
   jr z, ai_try_offset
   ld l, -1
   jr ai_try_offset
.either:
   call rng_sign
   ld l, a
   push hl
   call ai_try_offset
   pop hl
   ret nc
   ld a, l
   cpl
   inc a
   ld l, a
   ;; sigue en ai_try_offset

;;-----------------------------------------------------------------------------
;; ai_try_offset: mueve la oveja a (B + H, C + L) si se puede.
;; Una oveja encerrada solo puede pisar suelo de corral.
;; 📥 DE = entidad, B, C = posición actual, H = dy, L = dx (con signo)
;; 📤 carry a 0 si se movió, a 1 si no. Conserva BC y DE.
;; Modifica: A, F, HL
ai_try_offset:
   push bc
   ld a, b
   add h
   ld b, a
   ld a, c
   add l
   ld c, a                  ;; B, C = casilla destino
   push de
   push bc
   call level_is_blocked
   pop bc
   pop de
   jr c, .done              ;; valla u otra entidad

   ld a, [ai_entity_type]
   cp TYPE_SHEEP_PENNED
   jr nz, .move
   push de
   push bc
   call level_tile_at
   pop bc
   pop de
   cp TILE_CORRAL
   jr z, .move
   scf                      ;; encerrada: no puede salir del corral
   jr .done

.move:
   ld h, d
   ld a, E_Y
   add e
   ld l, a
   ld [hl], b
   inc l
   ld [hl], c
   and a                    ;; carry a 0: se movió
.done:
   pop bc                   ;; pop no toca los flags
   ret

;;-----------------------------------------------------------------------------
;; abs_a: valor absoluto de A (con signo).
;; Modifica: A, F
abs_a:
   bit 7, a
   ret z
   cpl
   inc a
   ret
