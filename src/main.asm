;;----------LICENSE NOTICE-------------------------------------------------------------------------------------------------------;;
;;  This file is part of GBTelera: A Gameboy Development Framework                                                               ;;
;;  Copyright (C) 2024 ronaldo / Cheesetea / ByteRealms (@FranGallegoBR)                                                         ;;
;;                                                                                                                               ;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ;;
;; files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,    ;;
;; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the         ;;
;; Softwareis furnished to do so, subject to the following conditions:                                                           ;;
;;                                                                                                                               ;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.;;
;;                                                                                                                               ;;
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ;;
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ;;
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ;;
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ;;
;;-------------------------------------------------------------------------------------------------------------------------------;;

   ; di     ;; Disable Interrupts
   ; halt   ;; Halt the CPU (stop procesing here)
; ============================================================
;  2048 for Game Boy  -  src/main.asm
; ============================================================

DEF REG_P1    EQU $FF00
DEF REG_DIV   EQU $FF04
DEF REG_LCDC  EQU $FF40
DEF REG_SCY   EQU $FF42
DEF REG_SCX   EQU $FF43
DEF REG_LY    EQU $FF44
DEF REG_BGP   EQU $FF47

; Tile indices in VRAM
DEF TILE_DARK  EQU 0     ; solid black (screen background)
DEF TILE_EMPTY EQU 1     ; empty cell (light grey)
DEF TILE_FILL  EQU 2     ; filled cell background (white)
DEF TILE_D0    EQU 3     ; digits 0-9 -> tiles 3..12

; Pad bits (after ReadPad: dpad low nibble, buttons high nibble)
DEF PAD_RIGHT EQU 0
DEF PAD_LEFT  EQU 1
DEF PAD_UP    EQU 2
DEF PAD_DOWN  EQU 3
DEF PAD_START EQU 7

; ------------------------------------------------------------
;  Variables (one aligned page so wBoard's address is $xx00)
; ------------------------------------------------------------
SECTION "Vars", WRAM0, ALIGN[8]
wBoard:     ds 16   ; each cell = exponent (0 empty, 1=2, 2=4 ... 13=8192)
wBoardOld:  ds 16
wLine:      ds 4
wScore:     ds 2
wDigits:    ds 5
wKeys:      ds 1
wPressed:   ds 1
wRand:      ds 1
wDrawRow:   ds 1    ; 0-3 = row pending redraw, 4 = idle
wLineCnt:   ds 1
wGameOver:  ds 1

; ------------------------------------------------------------

SECTION "Entry point", ROM0[$150]
main::
    di
    ld sp, $FFFE

    ; wait for VBlank, then turn LCD off
.waitvbl:
    ldh a, [REG_LY]
    cp 144
    jr c, .waitvbl
    xor a
    ldh [REG_LCDC], a

    ; load solid tiles (tiles 0-2)
    ld hl, Tiles
    ld de, $8000
    ld bc, TilesEnd - Tiles
    call CopyBytes

    ; load font (tiles 3-12), each byte written twice (both bitplanes)
    ld hl, Font
    ld de, $8030
    ld b, 80
.font:
    ld a, [hl+]
    ld [de], a
    inc de
    ld [de], a
    inc de
    dec b
    jr nz, .font

    ; clear tilemap with dark tile
    ld hl, $9800
    ld bc, $0400
.clr:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clr

    xor a
    ldh [REG_SCX], a
    ldh [REG_SCY], a

    call NewGame

    ld a, %10010001          ; LCD on, BG on, tiles at $8000, map $9800
    ldh [REG_LCDC], a

; ------------------------------------------------------------
;  Main loop
; ------------------------------------------------------------
.main:
    call WaitVBlank
    call VBlankDraw
    call ReadPad

    ld a, [wGameOver]
    or a
    jr nz, .over

    ld a, [wPressed]
    ld b, a
    bit PAD_LEFT, b
    ld a, 0
    jr nz, .move
    bit PAD_RIGHT, b
    ld a, 1
    jr nz, .move
    bit PAD_UP, b
    ld a, 2
    jr nz, .move
    bit PAD_DOWN, b
    ld a, 3
    jr nz, .move
    jr .main

.move:
    call DoMove
    jr .main

.over:
    ld a, [wPressed]
    bit PAD_START, a
    jr z, .main
    call NewGame
    jr .main

; ------------------------------------------------------------
WaitVBlank:
    ldh a, [REG_LY]
    cp 144
    jr nz, WaitVBlank
    ret

CopyBytes:                    ; HL=src DE=dst BC=count
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, CopyBytes
    ret

; ------------------------------------------------------------
;  New game: clears variables, spawns 2 tiles
; ------------------------------------------------------------
NewGame:
    ld a, [wKeys]
    push af                   ; keep pad state so a held START doesn't retrigger
    ld hl, wBoard
    ld b, 0                   ; 256 iterations
    xor a
.c:
    ld [hl+], a
    dec b
    jr nz, .c
    pop af
    ld [wKeys], a

    ldh a, [REG_DIV]
    or 1
    ld [wRand], a

    call SpawnTile
    call SpawnTile
    call ScoreToDigits

    ld a, %11100100
    ldh [REG_BGP], a
    xor a
    ld [wDrawRow], a          ; redraw everything
    ret

; ------------------------------------------------------------
;  Joypad
; ------------------------------------------------------------
ReadPad:
    ld a, $20                 ; select d-pad
    ldh [REG_P1], a
    REPT 4
    ldh a, [REG_P1]
    ENDR
    cpl
    and $0F
    ld b, a
    ld a, $10                 ; select buttons
    ldh [REG_P1], a
    REPT 6
    ldh a, [REG_P1]
    ENDR
    cpl
    and $0F
    swap a
    or b
    ld b, a                   ; B = current keys
    ld a, $30
    ldh [REG_P1], a

    ld a, [wKeys]
    ld c, a                   ; C = old keys
    ld a, b
    ld [wKeys], a
    ld a, c
    cpl
    and b                     ; newly pressed
    ld [wPressed], a
    ret

; ------------------------------------------------------------
;  Random (8-bit xorshift) -> A
; ------------------------------------------------------------
Random:
    ld a, [wRand]
    ld b, a
    and 1
    rrca
    xor b
    ld b, a
    srl a
    srl a
    srl a
    srl a
    srl a
    xor b
    ld b, a
    add a
    add a
    add a
    xor b
    ld [wRand], a
    ret

; ------------------------------------------------------------
;  Spawn a 2 (90%) or 4 (10%) in a random empty cell
; ------------------------------------------------------------
SpawnTile:
    ld hl, wBoard
    ld b, 16
    ld c, 0
.cnt:
    ld a, [hl+]
    or a
    jr nz, .nz
    inc c
.nz:
    dec b
    jr nz, .cnt
    ld a, c
    or a
    ret z                     ; board full

    ldh a, [REG_DIV]          ; mix in timing randomness
    ld b, a
    ld a, [wRand]
    xor b
    jr nz, .seeded
    inc a
.seeded:
    ld [wRand], a

    call Random
.mod:
    cp c
    jr c, .moddone
    sub c
    jr .mod
.moddone:
    ld d, a                   ; D = which empty cell

    call Random
    cp 26
    ld a, 1
    jr nc, .val
    inc a                     ; 2 -> exponent 2 = "4"
.val:
    ld e, a                   ; E = exponent to place

    ld hl, wBoard
.find:
    ld a, [hl]
    or a
    jr nz, .next
    ld a, d
    or a
    jr z, .place
    dec d
.next:
    inc hl
    jr .find
.place:
    ld [hl], e
    ret

; ------------------------------------------------------------
;  Move.  A = 0 left, 1 right, 2 up, 3 down
; ------------------------------------------------------------
DoMove:
    swap a                    ; dir * 16
    ld c, a
    ld b, 0
    ld hl, DirTable
    add hl, bc
    push hl

    ld hl, wBoard             ; backup board
    ld de, wBoardOld
    ld b, 16
.bk:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .bk

    pop hl                    ; HL = index table of this direction
    ld a, 4
    ld [wLineCnt], a

.line:
    push hl                   ; remember start of this line's indices
    ld b, HIGH(wBoard)
    ld de, wLine
    REPT 4
    ld a, [hl+]
    ld c, a
    ld a, [bc]
    ld [de], a
    inc de
    ENDR

    call SlideLine

    pop hl
    ld b, HIGH(wBoard)
    ld de, wLine
    REPT 4
    ld a, [hl+]
    ld c, a
    ld a, [de]
    inc de
    ld [bc], a
    ENDR

    ld a, [wLineCnt]
    dec a
    ld [wLineCnt], a
    jr nz, .line

    ; did anything change?
    ld hl, wBoard
    ld de, wBoardOld
    ld b, 16
.cmp:
    ld a, [de]
    inc de
    cp [hl]
    jr nz, .changed
    inc hl
    dec b
    jr nz, .cmp
    ret

.changed:
    call SpawnTile
    call ScoreToDigits
    xor a
    ld [wDrawRow], a
    call CanMove
    or a
    ret nz
    ld a, 1
    ld [wGameOver], a
    ld a, %00011011           ; inverted palette = game over
    ldh [REG_BGP], a
    ret

; ------------------------------------------------------------
;  Slide + merge wLine toward index 0 (in place)
; ------------------------------------------------------------
SlideLine:
    ld hl, wLine              ; read pointer
    ld de, wLine              ; write pointer
    ld b, 4
    ld c, 0                   ; last placed value (0 = can't merge)
.loop:
    ld a, [hl+]
    or a
    jr z, .next
    cp c
    jr nz, .place
    cp 13
    jr nc, .place
    ; merge with previous
    inc a
    dec de
    ld [de], a
    inc de
    push hl
    push bc
    push de
    add a
    ld e, a
    ld d, 0
    ld hl, PowTable
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [wScore]
    add l
    ld [wScore], a
    ld a, [wScore+1]
    adc h
    ld [wScore+1], a
    pop de
    pop bc
    pop hl
    ld c, 0
    jr .next
.place:
    ld [de], a
    inc de
    ld c, a
.next:
    dec b
    jr nz, .loop

    ; zero the rest
    ld a, e
    sub LOW(wLine)
    ld b, a
    ld a, 4
    sub b
    ret z
    ld b, a
    xor a
.z:
    ld [de], a
    inc de
    dec b
    jr nz, .z
    ret

; ------------------------------------------------------------
;  Can the player still move?  A=1 yes, 0 no
; ------------------------------------------------------------
CanMove:
    ld hl, wBoard
    ld b, 16
.empty:
    ld a, [hl+]
    or a
    jr z, .yes
    dec b
    jr nz, .empty

    ld hl, wBoard
    ld c, 0
.pair:
    ld a, c
    and 3
    cp 3
    jr z, .vert
    ld a, [hl]
    ld b, a
    inc hl
    ld a, [hl]
    dec hl
    cp b
    jr z, .yes
.vert:
    ld a, c
    cp 12
    jr nc, .nextc
    ld a, [hl]
    ld b, a
    push hl
    ld de, 4
    add hl, de
    ld a, [hl]
    pop hl
    cp b
    jr z, .yes
.nextc:
    inc hl
    inc c
    ld a, c
    cp 16
    jr nz, .pair
    xor a
    ret
.yes:
    ld a, 1
    ret

; ------------------------------------------------------------
;  Score (16-bit) -> 5 decimal digits in wDigits
; ------------------------------------------------------------
ScoreToDigits:
    ld a, [wScore]
    ld l, a
    ld a, [wScore+1]
    ld h, a
    ld de, wDigits
    ld bc, 10000
    call .digit
    ld bc, 1000
    call .digit
    ld bc, 100
    call .digit
    ld bc, 10
    call .digit
    ld a, l
    ld [de], a
    ret
.digit:
    xor a
    ld [de], a
.sub:
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc b
    jr c, .under
    ld h, a
    ld a, [de]
    inc a
    ld [de], a
    jr .sub
.under:
    ld a, l
    add c
    ld l, a
    inc de
    ret

; ------------------------------------------------------------
;  Drawing (one cell-row per frame, done inside VBlank)
; ------------------------------------------------------------
VBlankDraw:
    ld a, [wDrawRow]
    cp 4
    ret nc
    call DrawCellRow

    ld hl, $99C7              ; score: row 14, col 7
    ld de, wDigits
    REPT 5
    ld a, [de]
    add TILE_D0
    ld [hl+], a
    inc de
    ENDR

    ld a, [wDrawRow]
    inc a
    ld [wDrawRow], a
    ret

DrawCellRow:
    ld a, [wDrawRow]
    ld c, a
    ld hl, $9822              ; row 1, col 2 = board origin
    ld de, 96                 ; 3 tile rows per cell row
    inc c
.addr:
    dec c
    jr z, .addrdone
    add hl, de
    jr .addr
.addrdone:
    ld a, [wDrawRow]
    add a
    add a
    ld e, a
    ld d, HIGH(wBoard)        ; DE = &wBoard[row*4]
    ld b, 4
.cell:
    push bc
    push de
    push hl
    ld a, [de]
    call DrawCell
    pop hl
    ld de, 4
    add hl, de
    pop de
    inc de
    pop bc
    dec b
    jr nz, .cell
    ret

DrawCell:                     ; HL = top-left tile in map, A = exponent
    or a
    jr nz, .filled
    ld a, TILE_EMPTY
    ld b, 3
.er:
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld de, 28
    add hl, de
    dec b
    jr nz, .er
    ret
.filled:
    add a
    add a
    ld e, a
    ld d, 0
    push hl
    ld hl, DigitTable
    add hl, de
    ld d, h
    ld e, l
    pop hl
    ld bc, 28
    ld a, TILE_FILL
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    add hl, bc
    REPT 4
    ld a, [de]
    inc de
    ld [hl+], a
    ENDR
    add hl, bc
    ld a, TILE_FILL
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ret

; ============================================================
;  DATA
; ============================================================

; index tables: 4 lines x 4 cells per direction (left,right,up,down)
DirTable:
    db  0, 1, 2, 3,   4, 5, 6, 7,   8, 9,10,11,  12,13,14,15   ; left
    db  3, 2, 1, 0,   7, 6, 5, 4,  11,10, 9, 8,  15,14,13,12   ; right
    db  0, 4, 8,12,   1, 5, 9,13,   2, 6,10,14,   3, 7,11,15   ; up
    db 12, 8, 4, 0,  13, 9, 5, 1,  14,10, 6, 2,  15,11, 7, 3   ; down

; 2^exponent
PowTable:
    dw 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768

; 4 tile ids per exponent (right-aligned number)
DigitTable:
    db TILE_FILL,TILE_FILL,TILE_FILL,TILE_FILL                 ;  0 (unused)
    db TILE_FILL,TILE_FILL,TILE_FILL,TILE_D0+2                 ;  2
    db TILE_FILL,TILE_FILL,TILE_FILL,TILE_D0+4                 ;  4
    db TILE_FILL,TILE_FILL,TILE_FILL,TILE_D0+8                 ;  8
    db TILE_FILL,TILE_FILL,TILE_D0+1,TILE_D0+6                 ;  16
    db TILE_FILL,TILE_FILL,TILE_D0+3,TILE_D0+2                 ;  32
    db TILE_FILL,TILE_FILL,TILE_D0+6,TILE_D0+4                 ;  64
    db TILE_FILL,TILE_D0+1,TILE_D0+2,TILE_D0+8                 ;  128
    db TILE_FILL,TILE_D0+2,TILE_D0+5,TILE_D0+6                 ;  256
    db TILE_FILL,TILE_D0+5,TILE_D0+1,TILE_D0+2                 ;  512
    db TILE_D0+1,TILE_D0+0,TILE_D0+2,TILE_D0+4                 ;  1024
    db TILE_D0+2,TILE_D0+0,TILE_D0+4,TILE_D0+8                 ;  2048
    db TILE_D0+4,TILE_D0+0,TILE_D0+9,TILE_D0+6                 ;  4096
    db TILE_D0+8,TILE_D0+1,TILE_D0+9,TILE_D0+2                 ;  8192

; tiles 0-2: solid black, solid light grey, solid white (2 bytes per row)
Tiles:
    REPT 8
    db $FF,$FF
    ENDR
    REPT 8
    db $FF,$00
    ENDR
    REPT 8
    db $00,$00
    ENDR
TilesEnd:

; font 0-9, 8 bytes per glyph (duplicated into both bitplanes at load)
Font:
    db $3C,$66,$6E,$76,$66,$66,$3C,$00   ; 0
    db $18,$38,$18,$18,$18,$18,$7E,$00   ; 1
    db $3C,$66,$06,$0C,$18,$30,$7E,$00   ; 2
    db $3C,$66,$06,$1C,$06,$66,$3C,$00   ; 3
    db $0C,$1C,$3C,$6C,$7E,$0C,$0C,$00   ; 4
    db $7E,$60,$7C,$06,$06,$66,$3C,$00   ; 5
    db $3C,$66,$60,$7C,$66,$66,$3C,$00   ; 6
    db $7E,$66,$0C,$18,$18,$18,$18,$00   ; 7
    db $3C,$66,$66,$3C,$66,$66,$3C,$00   ; 8
    db $3C,$66,$66,$3E,$06,$66,$3C,$00   ; 9
