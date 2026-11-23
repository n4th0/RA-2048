;;==============================================================
;; Challenge 5 · Programa principal y pruebas
;;
;;   TEST = "game"        el juego completo.
;;   TEST = "test_ejNN"   las pruebas P1 y P2 del ejercicio NN (como en el Challenge 3):
;;                        BGB se para en cada `ld b, b`; compara CPU y MEM con el RESULTADO ESPERADO de ejNN.asm.
;;
;;   ❌ Solo se tocan estas líneas (DEF)
;;==============================================================
DEF TEST EQUS "game"  ;; ← Cambia TEST "test_ejNN" para probar casos de prueba de EJNN

INCLUDE "engine/hardware.inc"

;;==============================================================
;; Challenge 5 · Bucle principal del juego
;;
;;   Cada fotograma:
;;     1. input_update          Lee el joypad
;;     2. scene_update          La escena actual (menú, juego o game over).
;;                              El juego prepara ahí los sprites (pre-render)
;;     3. sys_render_update     Espera VBLANK y copia la sombra a la OAM
;;     4. hud_update            Si hace falta, redibuja los puntos (aún en VBLANK)
;;     5. fx_update             Efecto de paleta del botón Start (aún en VBLANK)
;;
;;   ❌ No lo modifiques
;;==============================================================

IF STRCMP("{TEST}", "game") == 0
SECTION "Entry point", ROM0[$150]

init_console::
   INCBIN "bin/init_console.bin"          ;; Rutina dada, en binario (24 bytes)

main::
   INCBIN "bin/main.bin"                  ;; Rutina dada, en binario (26 bytes)
ELSE
SECTION "Entry point", ROM0[$150]
main::
   ld   sp, WRAM_END
   call {TEST}
.end
   jr   .end
ENDC

INCLUDE "chcode/dispatch.inc"

IF STRCMP("{TEST}", "game") != 0
   INCLUDE "chcode/tests.inc"
   INCLUDE "chcode/tests/{TEST}.inc"
ENDC
