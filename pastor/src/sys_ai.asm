;;=============================================================================
;; sys_ai.asm — Sistema de IA: las ovejas huyen del pastor
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Cada SHEEP_STEP_FRAMES frames, cada oveja decide:
;;  - Si el pastor está cerca (|dx| + |dy| <= SHEEP_SCARE_DISTANCE), da un paso
;;    alejándose por el eje en el que está más lejos. Si ese paso está
;;    bloqueado, prueba el otro eje; si ninguno vale, se queda quieta.
;;  - Si no, a veces (SHEEP_GRAZE_CHANCE de cada 256) da un paso al azar.
;; Las ovejas encerradas hacen lo mismo, pero solo pueden pisar suelo de corral.
;;
;; dy y dx tienen signo: positivo = la oveja está debajo / a la derecha del
;; pastor. Los negativos son "dar la vuelta" en 8 bits: -1 = $FF (sesión 03.1).
;;=============================================================================
INCLUDE "constants.inc"

SECTION "AI state", WRAM0
ai_player_y:    DS 1
ai_player_x:    DS 1
ai_dy:          DS 1         ;; oveja.y - pastor.y
ai_dx:          DS 1         ;; oveja.x - pastor.x
ai_entity_type: DS 1         ;; tipo de la oveja que se está procesando

SECTION "AI system CODE", ROM0

;;-----------------------------------------------------------------------------
;; sys_ai_update: localiza al pastor y aplica la IA a cada oveja.
;; Llamar después de sys_input_update (así reaccionan en el mismo frame).
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
   ret nz                   ;; ni oveja suelta ni encerrada: no es cosa nuestra
.is_sheep:
   ld [ai_entity_type], a

   ;;--- Solo decide cada SHEEP_STEP_FRAMES frames ---
   ld a, E_COOLDOWN
   add e
   ld l, a
   ld a, [hl]
   cp 0
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

   ;;--- dy = oveja.y - pastor.y ;  dx = oveja.x - pastor.x ---
   ld a, [ai_player_y]
   ld l, a
   ld a, b
   sub l
   ld [ai_dy], a
   ld a, [ai_player_x]
   ld l, a
   ld a, c
   sub l
   ld [ai_dx], a

   ;;--- ¿Está el pastor cerca? distancia = |dy| + |dx| ---
   ld a, [ai_dy]
   call abs_a
   ld h, a                  ;; H = |dy|
   ld a, [ai_dx]
   call abs_a
   ld l, a                  ;; L = |dx|
   add h                    ;; A = distancia
   cp SHEEP_SCARE_DISTANCE + 1
   jr nc, .graze            ;; distancia > SCARE: no se asusta

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
   and %00000011            ;; dirección al azar: 0..3
   add a                    ;; 2 bytes por dirección
   ld hl, directions        ;; HL = directions + A (16 bits: add + adc)
   add l
   ld l, a
   ld a, h
   adc 0
   ld h, a
   ld a, [hl+]
   ld l, [hl]               ;; L = dx
   ld h, a                  ;; H = dy
   jp ai_try_offset

;; (dy, dx) de las 4 direcciones
directions:
   db -1,  0                ;; arriba
   db  1,  0                ;; abajo
   db  0, -1                ;; izquierda
   db  0,  1                ;; derecha

;;-----------------------------------------------------------------------------
;; ai_flee_vertical: un paso alejándose en vertical.
;; Si oveja y pastor están en la misma fila no hay "lejos": se prueba
;; un sentido al azar y, si está bloqueado, el contrario.
;; 📥 DE = entidad, B, C = posición actual
;; 📤 carry a 0 si se movió, a 1 si no
ai_flee_vertical:
   ld l, 0                  ;; en vertical, dx = 0
   ld a, [ai_dy]
   cp 0
   jr z, .either
   ld h, 1                  ;; dy positivo: está debajo del pastor, baja
   bit 7, a                 ;; bit 7 a 1 = número negativo
   jp z, ai_try_offset
   ld h, -1                 ;; dy negativo: está encima, sube
   jp ai_try_offset
.either:
   call rng_sign
   ld h, a
   push hl
   call ai_try_offset
   pop hl
   ret nc
   xor a                    ;; H = 0 - H: el sentido contrario
   sub h
   ld h, a
   jp ai_try_offset

;;-----------------------------------------------------------------------------
;; ai_flee_horizontal: igual que ai_flee_vertical, pero en horizontal.
ai_flee_horizontal:
   ld h, 0                  ;; en horizontal, dy = 0
   ld a, [ai_dx]
   cp 0
   jr z, .either
   ld l, 1                  ;; dx positivo: está a la derecha, va a la derecha
   bit 7, a
   jp z, ai_try_offset
   ld l, -1
   jp ai_try_offset
.either:
   call rng_sign
   ld l, a
   push hl
   call ai_try_offset
   pop hl
   ret nc
   xor a                    ;; L = 0 - L
   sub l
   ld l, a
   jp ai_try_offset

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
   jr c, .done              ;; valla u otra entidad: no se mueve (carry a 1)

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
   xor a                    ;; carry a 0: se movió
.done:
   pop bc                   ;; pop no toca los flags
   ret

;;-----------------------------------------------------------------------------
;; abs_a: valor absoluto de A (con signo).
;; Modifica: A, F (conserva BC, DE y HL)
abs_a:
   bit 7, a
   ret z                    ;; positivo: se queda igual
   push bc
   ld b, a                  ;; negativo: A = 0 - A
   xor a
   sub b
   pop bc
   ret
