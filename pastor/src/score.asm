;;=============================================================================
;; score.asm — Puntuación y récord guardado en la RAM del cartucho
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Los puntos se guardan con UN DÍGITO POR BYTE, el más alto primero:
;;     score: 0, 0, 1, 2, 3, 0   =  001230 puntos
;; Sumar es como en el colegio: si un dígito pasa de 9, se le resta 10 y
;; nos llevamos 1 al de su izquierda. Y para pintar un dígito basta con
;; sumarle TILE_DIGIT_0.
;;
;; El récord se guarda en la SRAM con batería (cartucho $03 de la cabecera:
;; MBC1 + RAM + BATTERY), que no se borra al apagar. Una SRAM nueva trae
;; basura, así que delante del récord va una firma: si no está, récord = 0.
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

DEF SIGNATURE_SIZE EQU 4

SECTION "Score state", WRAM0
score::      DS SCORE_DIGITS ;; puntos de la partida
record::     DS SCORE_DIGITS ;; mejor puntuación (copia en WRAM de la SRAM)
new_record:: DS 1            ;; 1 si la última partida batió el récord

SECTION "Save data", SRAM
save_signature: DS SIGNATURE_SIZE
save_record:    DS SCORE_DIGITS

SECTION "Score CODE", ROM0

save_signature_rom:
   db "PSTR"                ;; este fichero no usa CHARMAP: son letras ASCII normales

;;-----------------------------------------------------------------------------
;; score_reset: puntuación a 0 al empezar una partida.
;; Modifica: A, F, B, HL
score_reset::
   ld hl, score
   ld b, SCORE_DIGITS
   xor a
.clear:
   ld [hl+], a
   dec b
   jr nz, .clear
   ret

;;-----------------------------------------------------------------------------
;; score_add_digit: suma A (0..9) a un dígito de la puntuación, llevando
;; el acarreo hacia la izquierda.
;; Los dígitos son score + 0 (centenas de millar) ... score + 5 (unidades):
;;    10 puntos -> HL = score + 4 (decenas),  A = 1
;;   100 puntos -> HL = score + 3 (centenas), A = 1
;; Con 6 dígitos no se llega nunca a desbordar (999999), así que no se comprueba.
;; 📥 HL = dígito donde sumar, A = cantidad (0..9)
;; Modifica: A, F, HL
score_add_digit::
   add [hl]                 ;; A = dígito + cantidad
   cp 10
   jr c, .store             ;; < 10: cabe en el dígito
   sub 10                   ;; >= 10: me quedo con las unidades...
   ld [hl], a
   dec hl                   ;; ...y me llevo 1 al dígito de la izquierda
   ld a, 1
   jr score_add_digit
.store:
   ld [hl], a
   ld a, 1
   ld [hud_dirty], a        ;; que el marcador se repinte
   ret

;;-----------------------------------------------------------------------------
;; record_load: lee el récord de la SRAM. Llamar una vez al arrancar.
;; Modifica: A, F, BC, DE, HL
record_load::
   ld a, CART_SRAM_ENABLE   ;; abrir la SRAM (escribiendo $0A en $0000)
   ld [rRAMG], a

   ld hl, save_signature    ;; ¿hay firma? compararla byte a byte
   ld de, save_signature_rom
   ld b, SIGNATURE_SIZE
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
   ld bc, SCORE_DIGITS
   call memcpy
   jr .close

.empty:                     ;; sin firma: récord = 0
   ld hl, record
   ld b, SCORE_DIGITS
   xor a
.clear:
   ld [hl+], a
   dec b
   jr nz, .clear

.close:
   ld a, CART_SRAM_DISABLE  ;; cerrar la SRAM protege los datos si se apaga
   ld [rRAMG], a
   ret

;;-----------------------------------------------------------------------------
;; record_check: si la puntuación supera el récord, lo actualiza y lo guarda.
;; Llamar al acabar la partida (ganada o perdida).
;; Se compara dígito a dígito desde el más alto: el primero distinto decide.
;; 📤 new_record = 1 si se batió
;; Modifica: A, F, BC, DE, HL
record_check::
   xor a
   ld [new_record], a
   ld hl, score
   ld de, record
   ld b, SCORE_DIGITS
.compare:
   ld a, [de]
   cp [hl]                  ;; récord - puntos
   jr c, .beaten            ;; carry: puntos > récord en este dígito
   ret nz                   ;; puntos < récord: no hay récord nuevo
   inc hl                   ;; iguales: mirar el siguiente dígito
   inc de
   dec b
   jr nz, .compare
   ret                      ;; empate: tampoco es récord nuevo

.beaten:
   ld a, 1
   ld [new_record], a
   ld hl, score             ;; record = score
   ld de, record
   ld bc, SCORE_DIGITS
   call memcpy

   ld a, CART_SRAM_ENABLE   ;; guardar firma y récord en la SRAM
   ld [rRAMG], a
   ld hl, save_signature_rom
   ld de, save_signature
   ld bc, SIGNATURE_SIZE
   call memcpy
   ld hl, record
   ld de, save_record
   ld bc, SCORE_DIGITS
   call memcpy
   ld a, CART_SRAM_DISABLE
   ld [rRAMG], a
   ret
