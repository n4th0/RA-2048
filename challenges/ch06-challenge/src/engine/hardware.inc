;;==============================================================
;; Challenge 6 · Hardware: registros, pantalla, OAM y botones
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(HARDWARE_INC)
DEF HARDWARE_INC = 1
;;--------------------------------------------------------------
;; Registers
;;--------------------------------------------------------------
DEF rP1    = $FF00               ;; Joypad
DEF rDIV   = $FF04               ;; Divider (changes all the time)
DEF rLCDC  = $FF40               ;; LCD control. Bit 7: LCD on/off
DEF rSCY   = $FF42               ;; Scroll Y: pixels the background moves up
DEF rSCX   = $FF43               ;; Scroll X: pixels the background moves left
DEF rLY    = $FF44               ;; Line being drawn (144-153: VBLANK)
DEF rDMA   = $FF46               ;; DMA: writing a page here copies 160 bytes to OAM
DEF rBGP   = $FF47               ;; Background palette
DEF rOBP0  = $FF48               ;; Sprite palette 0
DEF rOBP1  = $FF49               ;; Sprite palette 1 (sprites with ATTR bit 4)
DEF rWY    = $FF4A               ;; Window: first line where it is drawn
DEF rWX    = $FF4B               ;; Window: its column + 7

;; Sound. The registers of channel 4 (noise) are the ones the sound effects use
DEF rAUD4LEN  = $FF20            ;; Channel 4: length
DEF rAUD4ENV  = $FF21            ;; Channel 4: volume and how it fades (envelope)
DEF rAUD4POLY = $FF22            ;; Channel 4: noise pitch and type
DEF rAUD4GO   = $FF23            ;; Channel 4: bit 7 starts it, bit 6 uses the length
DEF rAUDVOL   = $FF24            ;; Master volume (bits 6-4 left, bits 2-0 right)
DEF rAUDTERM  = $FF25            ;; Which channels go to which speaker (1 bit each)
DEF rAUDENA   = $FF26            ;; Bit 7: sound on/off (off: other writes are lost)
DEF AUDENA_ON   = %10000000          ;; sound on
DEF AUDTERM_ALL = %11111111          ;; the 4 channels on both speakers
DEF AUDVOL_MAX  = %01110111          ;; maximum volume on both speakers

DEF VBLANK_LINE   = 144
DEF SCREEN_WIDTH  = 160
DEF SCREEN_HEIGHT = 144
DEF LCDC_ON_BIT   = 7
DEF LCDC_VALUE    = %11110111    ;; LCD on · window map $9C00 · window on ·
                                 ;; tiles at $8000 · background map $9800 ·
                                 ;; sprites 8x16 · sprites on · background on
DEF PALETTE       = %11100100    ;; colour 0 = white ... colour 3 = black
DEF PALETTE_HURT  = %00011011    ;; the colours reversed (a hurt hero flashes with it)

DEF VRAM_TILES    = $8000
DEF TILEMAP       = $9800        ;; the background: 32 x 32 tiles = 256 x 256 pixels
DEF WINDOW_MAP    = $9C00        ;; the window (the HUD): it does not scroll
DEF TILEMAP_WIDTH = 32
DEF OAM_START     = $FE00
DEF OAM_SIZE      = 160          ;; 40 sprites x 4 bytes
DEF HRAM_START    = $FF80
DEF WRAM_END      = $E000

;;--------------------------------------------------------------
;; Sprites: ATTR bits (the 4th byte of a sprite in the OAM)
;;--------------------------------------------------------------
DEF ATTR_PALETTE_BIT = 4         ;; 0 = palette 0 (rOBP0), 1 = palette 1 (rOBP1)
DEF ATTR_XFLIP_BIT   = 5         ;; 1 = mirrored horizontally
DEF ATTR_YFLIP_BIT   = 6         ;; 1 = mirrored vertically
DEF ATTR_PALETTE     = 1 << ATTR_PALETTE_BIT
DEF ATTR_XFLIP       = 1 << ATTR_XFLIP_BIT
DEF ATTR_YFLIP       = 1 << ATTR_YFLIP_BIT

;; Sprites are 8x16: each one shows two tiles, tile N above tile N + 1.
;; An entity (16x16 pixels) is drawn with 2 sprites, side by side.
DEF SPRITES_PER_ENTITY = 2
DEF SPRITE_WIDTH       = 8       ;; pixels
DEF TILES_PER_SPRITE   = 2       ;; an 8x16 sprite shows 2 tiles
;; The position of a sprite in the OAM is the position on the screen plus this, so that
;; a sprite can be partly outside the screen (Y = 0 or X = 0: completely hidden)
DEF OAM_Y_OFFSET       = 16
DEF OAM_X_OFFSET       = 8
;; How the 40 OAM SPRITE slots are used:
;;   slots  0-23  the entities (2 sprites each): DMA copies shadow_oam every frame
;;   slots 24-39  unused (hidden)
;;--------------------------------------------------------------
;; Buttons (input_held / input_pressed). 1 = pressed
;;--------------------------------------------------------------
DEF BTN_RIGHT_BIT  = 0
DEF BTN_LEFT_BIT   = 1
DEF BTN_UP_BIT     = 2
DEF BTN_DOWN_BIT   = 3
DEF BTN_A_BIT      = 4
DEF BTN_B_BIT      = 5
DEF BTN_SELECT_BIT = 6
DEF BTN_START_BIT  = 7
DEF BTN_A          = 1 << BTN_A_BIT
DEF BTN_START      = 1 << BTN_START_BIT

ENDC
