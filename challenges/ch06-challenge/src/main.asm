;;==============================================================
;; Challenge 6 · Programa principal y pruebas
;;
;;   TEST = "game"        el juego completo.
;;   TEST = "test_ejNN"   las pruebas P1 y P2 del ejercicio NN (como en el Challenge 3):
;;                        BGB se para en cada `ld b, b`; compara CPU y MEM con el RESULTADO ESPERADO de ejNN.asm.
;;
;;   El juego completo solo funciona cuando están hechos TODOS los ejercicios (y los de corregir, renombrados a ejNN.asm).
;;
;;   ❌ Solo se tocan estas líneas (DEF)
;;==============================================================
DEF TEST EQUS "test_ej01"  ;; ← "test_ejNN" casos de prueba
                           ;; ← "game" juego completo


INCLUDE "engine/hardware.inc"

;;==============================================================
;; Challenge 6 · Bucle principal del juego
;;
;;   Cada frame:
;;     1. input_update          Lee el joypad
;;     2. scene_update          La escena actual (menú, juego, game over o victoria).
;;                              El juego prepara ahí los sprites (pre-render)
;;     3. sys_render_update     Espera VBLANK, copia la Shadow OAM a la OAM (DMA) y hace el scroll
;;     4. hud_update            Si hace falta, redibuja el HUD (aún en VBLANK)
;;     5. sound_update          Un tick de la música. Va tras el render para que se ejecute
;;                              siempre en el mismo punto del frame y el tempo sea constante
;;
;;   ❌ No lo modifiques
;;==============================================================

IF STRCMP("{TEST}", "game") == 0
SECTION "Entry point", ROM0[$150]

init_console::
   call input_init              ;; \ Each module initializes
   call frame_init              ;; | its own state
   call hud_init                ;; |
   call sound_init              ;; /

   call screen_off              ;; \ The console starts with the screen on: off (the safe way)
   call gfx_init                ;; | Tiles and palettes (the screen is off)
   call dma_init                ;; | The DMA routine, copied to HRAM
   call oam_clear               ;; / The OAM and the RAM have garbage: no sprites

   ld   hl, scene_menu          ;; \ The game starts in the menu
   jp   scene_change            ;; / (scene_change turns the screen on)
;; ret ;; Tail-call-optimization

main::
   ld   sp, WRAM_END            ;; The stack grows down from the end of the WRAM
   call init_console

.do_frame
   call input_update            ;; \ Read the joypad
   call frame_tick              ;; | One more frame
   call scene_update            ;; / The update of the current scene

   call sys_render_update       ;; \ Wait for VBLANK, show the sprites and scroll
   call hud_update              ;; / Still in VBLANK: the hud
   call sound_update            ;; The music: one tick (after the render, so always at the same point)

   jr   .do_frame               ;; Next frame
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
