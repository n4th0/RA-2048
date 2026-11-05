INCLUDE "hardware.inc"
INCLUDE "constants.inc"

DEF SIGNATURE_SIZE EQU 4

SECTION "Score state", WRAM0
score::      DS SCORE_DIGITS 
record::     DS SCORE_DIGITS 
new_record:: DS 1            

SECTION "Save data", SRAM
save_signature: DS SIGNATURE_SIZE
save_record:    DS SCORE_DIGITS

SECTION "Score CODE", ROM0

save_signature_rom:
   db "PSTR"               



score_reset::
   ld hl, score
   ld b, SCORE_DIGITS
   xor a
.clear:
   ld [hl+], a
   dec b
   jr nz, .clear
   ret


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
