;;==============================================================
;; Challenge 6 · Sistema de pre-render (componente SPRITE)
;; Prepara los sprites de las entidades en la Shadow OAM, en RAM: pasa cada entidad
;; de coordenadas del MUNDO a coordenadas de PANTALLA (restando la cámara) y la
;; dibuja con 2 sprites de 8x16, uno al lado del otro.
;; Copiar la Shadow OAM a la OAM no se hace aquí: es sys_render_update.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "engine/ui/hud.inc"

SECTION "Prerender data", WRAM0
shadow_cursor::   DS 1   ;; Holds the position inside shadow_oam (only its low byte:
                        ;; shadow_oam is aligned) where the next sprite should be written

SECTION "System: prerender", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 09: `world_to_oam`
;; La implementas TÚ, en src/ej09.asm (etiqueta `ej09::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `world_to_oam` y no necesita saber dónde está tu código.
world_to_oam::
   jp   go_ej09              ;; Salta al ejercicio 09 (ver main.asm)
   ds   12, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 10: `sys_prerender_one`
;; La implementas TÚ, en src/ej10.asm (etiqueta `ej10::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_prerender_one` y no necesita saber dónde está tu código.
sys_prerender_one::
   jp   go_ej10              ;; Salta al ejercicio 10 (ver main.asm)
   ds   59, $00              ;; Relleno: las demás rutinas conservan su dirección
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prepares the whole shadow OAM (in RAM, so no hurry and no need for VBLANK):
;;  1. Fills the sprites of the entities with zeros (Y = 0: every sprite hidden), so
;;     that the entities that no longer exist do not leave sprites behind.
;;  2. Puts shadow_cursor at the start of the shadow OAM.
;;  3. Prepares every entity with sys_prerender_one.
;; ❌ May modify A, BC, DE, HL
sys_prerender_update::
   INCBIN "bin/sys_prerender_update.bin"  ;; Rutina dada, en binario (22 bytes)
