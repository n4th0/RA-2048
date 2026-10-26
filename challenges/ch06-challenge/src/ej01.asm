;;==============================================================
;; Challenge 6 · Ejercicio 01 · DMARoutine y dma_init: Encuentra y corrige los errores
;;==============================================================
;;
;; CÓMO TRABAJAR
;;  1. El código con errores YA ESTÁ aquí abajo, igual que en el papel: no lo copies. Corrígelo aquí mismo.
;;     Este fichero se llama ej01.asm.no para que el proyecto compile mientras tanto. Cuando empieces,
;;     renómbralo a ej01.asm.
;;  2. Cada corrección, con su comentario:  ;; FIX <tipo><nº>: <motivo>   (N, E, S, F)
;;       N: no existe · E: errónea · S: sintaxis · F: falta algo
;;  3. Prueba: en main.asm, DEF TEST EQUS "test_ej01" y make. BGB para en cada `ld b, b` (P1, P2).
;;     Compara CPU y MEM con el RESULTADO ESPERADO del final de este fichero.
;;  4. Rellena el resumen del final.
;;
;; DÓNDE ESTÁ
;;   `dma_init` está en src/engine/dma.asm. Allí solo hay un salto: tu código va AQUÍ, en `ej01::`.
;;   `DMARoutine` estaba allí también, justo encima: ahora está en este fichero, con `dma_init`.
;;
;; QUÉ HAY QUE HACER
;;   Distinto al entrenamiento: la espera gasta 5 ciclos por vuelta (`dec`, `nop` y `jr nz`) y da `DMA_WAIT_LOOPS` = 32 vueltas.
;;
;;   `DMARoutine` es el código que ejecuta la CPU desde HRAM y `dma_init` lo copia a `hDMARoutine` con `memcpy8`, como en el entrenamiento.
;;
;;   El código completo viene con errores de todo tipo. Encuéntralos y arréglalos.
;;
;; PISTAS
;;   - Cuenta los ciclos de una vuelta del bucle. La copia dura 160 ciclos y la CPU no puede salir de HRAM antes.
;;   - `dma_run` ejecuta `hDMARoutine` con un `jp`: ¿cómo vuelve a quien la llamó?
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "engine/ui/hud.inc"
INCLUDE "scn/scn_game.inc"
INCLUDE "assets/levels/levels.inc"

DEF DMA_WAIT_LOOPS   = 32        ;; 32 loops x 5 cycles = 160 cycles: what the copy lasts

SECTION "Ejercicio 01", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This is the code that will run from HRAM (see dma_init). Its addresses are absolute
;; (ldh [rDMA]...) and it uses no jumps to the outside, so it works from any place.
DMARoutine:
   ld   a, HIGH(shadow_oam)     ;; \ rDMA = the page of the shadow OAM:
   ldh  [rDMA], a               ;; / the copy starts now
   ld   a, DMA_WAIT_LOOPS        ;; \ Wait for the copy to end, ; S: DMA_WAIT_LOOP -> DMA_WAIT_LOOPS
.wait                           ;; | doing nothing (only HRAM can be read):
   dec  a                       ;; | 32 loops x 5 cycles:
   nop
   jr   nz, .wait                ;; / ; E: jr nz, .wait 
   ret
 ; F: ret
DMARoutineEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copies the DMA routine to HRAM. It is done once, when the console starts.
;; ❌ Modifies A, B, DE, HL
ej01::   ;; = `dma_init`, que está en src/engine/dma.asm
   ld   hl, DMARoutine         ;; \ HL = the routine in the ROM; E  hDMARoutine -> DMARoutine
   ld   de, hDMARoutine          ;; | DE = its place in HRAM ; E DMARoutine -> hDMARoutine
   ld   b, DMARoutineEnd - DMARoutine ;; | B = its size
   jp   memcpy8                 ;; / Copy it

;; ==========================================================
;;  ENSAMBLA: ____  (SÍ / NO)
;; === CASOS DE PRUEBA   (test_ej01 en main.asm)
;;  * Comprobar que CPU y MEM coinciden con el valor esperado
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 1: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> La HRAM (hDMARoutine, 16 bytes) está llena de EE.
;; [MEM] hDMARoutine (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FF80  3E C1 E0 46 3E 20 3D 00|20 FC C9 EE EE EE EE EE|
;;  dma_init copia los 11 bytes de DMARoutine (3E C1 E0 46 3E 20 3D 00 20 FC C9) a HRAM: la espera tiene un `nop` (00) y cuenta 32 (20). Los otros 5 bytes siguen en EE.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; * CASO 2: ____  (OK / Falla)
;;
;;        >>>>> RESULTADO ESPERADO (Comprobar) <<<<<
;; [PREVIO]> shadow_oam = 00, 01, 02 ... 9F (160 bytes). La OAM (FE00-FE9F), llena de FF. Se llama a dma_init y después a hDMARoutine.
;; [MEM] FE00 (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FE00  00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;; [MEM] FE90 (16 bytes)
;;         00 01 02 03 04 05 06 07|08 09 0A 0B 0C 0D 0E 0F|
;;   FE90  90 91 92 93 94 95 96 97|98 99 9A 9B 9C 9D 9E 9F|
;;  La OAM queda como la shadow_oam: 00, 01 ... 9F. Se muestran los primeros y los últimos 16 bytes de los 160.
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; ==========================================================
;; === FIXES
;;  Tipo: Cant.
;;  *  N:    __     (no existe)
;;  *  E:    00     (errónea)
;;  *  S:    00     (sintaxis)
;;  *  F:    01     (falta algo)
;;
;; EXPLICACIONES ADICIONALES DE FIXES (si es necesario)
;; faltaba un nop
;;  *
;;
