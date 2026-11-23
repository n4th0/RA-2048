;;==============================================================
;; Challenge 5 · Hardware: registros, pantalla, OAM y botones
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
DEF rLY    = $FF44               ;; Line being drawn (144-153: VBLANK)
DEF rBGP   = $FF47               ;; Background palette
DEF rOBP0  = $FF48               ;; Sprite palette 0
DEF rOBP1  = $FF49               ;; Sprite palette 1 (sprites with ATTR bit 4)

DEF VBLANK_LINE   = 144
DEF LCDC_ON_BIT   = 7
DEF LCDC_VALUE    = %10010011    ;; LCD on · tiles at $8000 · sprites on · background on
DEF PALETTE       = %00011011    ;; colour 0 = black ... colour 3 = white

DEF VRAM_TILES    = $8000
DEF TILEMAP       = $9800
DEF TILEMAP_WIDTH = 32
DEF OAM_START     = $FE00
DEF OAM_SIZE      = 160          ;; 40 sprites x 4 bytes
DEF WRAM_END      = $E000

;; How the 40 OAM SPRITE slots are used:
;;   slots  0-7   the start button (written once) ui/start_button.asm
;;   slots  8-15  the entities (copied from shadow_oam every frame)  sys/sys_render.asm
;;   slots 16-39  unused (hidden)
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
