;;==============================================================
;; Challenge 6 · DMA: copiar la Shadow OAM a la OAM
;; Copiar los 160 bytes con la CPU (memcpy8: 10 ciclos por byte, 1600 en total) no
;; cabe en el VBLANK (unos 1140 ciclos). El hardware lo hace solo y mucho más rápido:
;; DMA (Direct Memory Access). Se le dice de qué PÁGINA de memoria copiar (la parte
;; alta de la dirección) escribiendo en rDMA, y copia 160 bytes a la OAM en 160 ciclos.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"

DEF DMA_ROUTINE_MAX  = 16        ;; bytes reserved in HRAM for DMARoutine (it must fit: checked below)

;; The routine that starts the DMA has to RUN FROM HRAM. While the DMA copies (160
;; cycles), the CPU cannot read the ROM or the WRAM: the bus is busy. HRAM is the
;; only memory the CPU can still read. So the routine lives in the ROM (as data)
;; and dma_init copies it to HRAM once, at the start. From then on, hDMARoutine is called.
SECTION "HRAM: DMA routine", HRAM
hDMARoutine::    DS DMA_ROUTINE_MAX   ;; where DMARoutine is copied: it runs from here

SECTION "Engine: DMA", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 01: `DMARoutine`, el código que se copia a HRAM
;; La corriges TÚ, en src/ej01.asm (junto con `dma_init`). En el juego completo ocupaba este sitio:
;; ahora solo hay relleno, para que las demás rutinas conserven su dirección.
   ds   11, $00       ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 01: `dma_init`
;; La implementas TÚ, en src/ej01.asm (etiqueta `ej01::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `dma_init` y no necesita saber dónde está tu código.
dma_init::
   jp   go_ej01              ;; Salta al ejercicio 01 (ver main.asm)
   ds   8, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copies the whole shadow OAM to the OAM (160 bytes), by DMA.
;; ⚠️ Call it in VBLANK: the OAM changes right now, not in the middle of a frame.
;; ❌ Modifies A
dma_run::
   INCBIN "bin/dma_run.bin"               ;; Rutina dada, en binario (3 bytes)
