;;==============================================================
;; Challenge 6 · OAM: la Shadow OAM y oam_clear
;; La Shadow OAM es una copia de la OAM (los 40 sprites) en la WRAM, donde se
;; puede escribir en cualquier momento. Quien dibuja prepara ahí los sprites,
;; y en VBLANK se copia a la OAM de golpe con DMA (engine/dma.asm).
;; Es general: no sabe nada de entidades.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

;; ALIGN[8]: DMA copies from a whole page of memory ($xx00-$xxFF), so the
;; shadow OAM must start at an address ending in $00. This also means a position
;; inside it is just a byte: the low byte of the address (HIGH(shadow_oam) never changes).
SECTION "OAM data", WRAM0, ALIGN[8]
shadow_oam::     DS OAM_SIZE          ;; copy of the OAM (40 sprites), in WRAM

SECTION "Engine: OAM", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hides EVERY sprite: it empties the whole OAM (40 sprites) and the
;; shadow OAM. A scene calls this when it starts and wants to be sure that
;; nothing is left from the previous one (Y = 0 is off the screen).
;; ⚠️ The screen must be OFF (or be in VBLANK): the OAM is written
;; ❌ Modifies A, B, HL
oam_clear::
   ld   hl, OAM_START           ;; \ HL = the OAM
   xor  a                       ;; | A = 0 (Y = 0: sprite hidden)
   ld   b, OAM_SIZE             ;; | B = its size (40 sprites)
   call memset8                 ;; / Empty the OAM

   ld   hl, shadow_oam          ;; \ HL = the shadow OAM
   xor  a                       ;; | A = 0
   ld   b, OAM_SIZE             ;; | B = its size
   jp   memset8                 ;; / Empty the shadow OAM too
