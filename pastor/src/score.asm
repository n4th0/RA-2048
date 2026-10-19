;;=============================================================================
;; score.asm — Puntuación en BCD y récord guardado en la RAM del cartucho
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; BCD: cada byte guarda 2 dígitos decimales ($42 = "42"). Tras sumar en
;; binario, `daa` corrige el resultado para que siga siendo BCD. Así no hay
;; que dividir entre 10 para pintar: cada nibble ya es un dígito.
;;
;; El récord se guarda en la SRAM con batería (cartucho $03: MBC1+RAM+BATTERY).
;; Una SRAM nueva trae basura, así que delante del récord va una firma: si no
;; está, el récord se considera 0.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Score state", WRAM0
score::      DS SCORE_BYTES  ;; puntos de la partida
record::     DS SCORE_BYTES  ;; mejor puntuación (copia en WRAM de la SRAM)
new_record:: DS 1            ;; 1 si la última partida batió el récord

SECTION "Save data", SRAM
save_signature: DS 4
save_record:    DS SCORE_BYTES

SECTION "Score CODE", ROM0

save_signature_rom:
   db "PSTR"                ;; sin charmap: códigos ASCII

;;-----------------------------------------------------------------------------
;; score_reset: puntuación a 0 al empezar una partida.
;; Modifica: A, HL
score_reset::
   xor a
   ld hl, score
   ld [hl+], a
   ld [hl+], a
   ld [hl], a
   ret

;;-----------------------------------------------------------------------------
;; score_add: suma un número BCD de 4 dígitos a la puntuación.
;; Si se pasa de 999999 da la vuelta: con estos niveles no se llega.
;; 📥 B = 2 dígitos altos, C = 2 dígitos bajos (p. ej. 1230 puntos: B=$12, C=$30)
;; Modifica: A, F, HL
score_add::
   ld hl, score + SCORE_BYTES - 1   ;; byte menos significativo
   ld a, [hl]
   add c
   daa
   ld [hl-], a
   ld a, [hl]
   adc b                    ;; el acarreo decimal pasa al siguiente byte
   daa
   ld [hl-], a
   ld a, [hl]
   adc 0
   daa
   ld [hl], a
   ld hl, hud_dirty
   set HUDB_SCORE, [hl]
   ret

;;-----------------------------------------------------------------------------
;; score_add_time_bonus: suma 10 puntos por cada segundo que sobra.
;; tiempo (BCD de 3 dígitos) * 10 = desplazar un dígito a la izquierda:
;; $01 $45 segundos -> 1450 puntos = B $14, C $50.
;; Modifica: A, F, BC, HL
score_add_time_bonus::
   ld a, [time_left + 1]
   swap a
   ld c, a                  ;; C = unidades|decenas cambiadas de sitio
   and $F0
   ld b, a                  ;; (guardamos las unidades, ya en el nibble alto)
   ld a, c
   and $0F                  ;; A = decenas de segundos
   ld c, a
   ld a, [time_left]
   swap a
   and $F0                  ;; centenas de segundos -> nibble alto
   or c
   ld c, b                  ;; C = unidades * 10  (p. ej. $50)
   ld b, a                  ;; B = centenas|decenas (p. ej. $14)
   jr score_add

;;-----------------------------------------------------------------------------
;; record_load: lee el récord de la SRAM. Llamar una vez al arrancar.
;; Modifica: A, F, BC, DE, HL
record_load::
   ld a, CART_SRAM_ENABLE
   ld [rRAMG], a

   ld hl, save_signature    ;; ¿hay firma?
   ld de, save_signature_rom
   ld b, 4
.check:
   ld a, [de]
   cp [hl]
   jr nz, .empty
   inc hl
   inc de
   dec b
   jr nz, .check

   ld hl, save_record       ;; firma correcta: copiar el récord
   ld de, record
   ld bc, SCORE_BYTES
   call memcpy
   jr .done
.empty:
   ld hl, record
   xor a
   ld [hl+], a
   ld [hl+], a
   ld [hl], a
.done:
   ld a, CART_SRAM_DISABLE  ;; cerrar la SRAM protege los datos si se apaga
   ld [rRAMG], a
   ret

;;-----------------------------------------------------------------------------
;; record_check: si la puntuación supera el récord, lo actualiza y lo guarda.
;; Llamar al acabar la partida (ganada o perdida).
;; 📤 new_record = 1 si se batió
;; Modifica: A, F, BC, DE, HL
record_check::
   xor a
   ld [new_record], a
   ld hl, score             ;; comparar del byte más significativo al menor
   ld de, record
   ld b, SCORE_BYTES
.compare:
   ld a, [de]
   cp [hl]                  ;; record - score
   jr c, .beaten            ;; score > record en este byte
   ret nz                   ;; score < record
   inc hl
   inc de
   dec b
   jr nz, .compare
   ret                      ;; empate: no es récord nuevo

.beaten:
   ld a, 1
   ld [new_record], a
   ld hl, score
   ld de, record
   ld bc, SCORE_BYTES
   call memcpy

   ld a, CART_SRAM_ENABLE
   ld [rRAMG], a
   ld hl, save_signature_rom
   ld de, save_signature
   ld bc, 4
   call memcpy
   ld hl, record
   ld de, save_record
   ld bc, SCORE_BYTES
   call memcpy
   ld a, CART_SRAM_DISABLE
   ld [rRAMG], a
   ret

ASSERT SCORE_BYTES == 3, "score_add y score_reset asumen 3 bytes"
