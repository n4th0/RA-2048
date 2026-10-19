;;==============================================================
;; Challenge 5 · OAM: la OAM sombra y oam_clear
;; La OAM sombra es una copia de la OAM (los 40 sprites) en la WRAM, donde se
;; puede escribir en cualquier momento. Quien dibuja prepara ahí los sprites,
;; y se copian a la OAM en VBLANK. Es general: no sabe nada de entidades.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

;; ALIGN[8]: it starts at an address ending in $00 (LOW(shadow_oam) = 0), so an
;; offset inside it is just the low byte of the address.
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
   INCBIN "bin/oam_clear.bin"             ;; Rutina dada, en binario (18 bytes)
