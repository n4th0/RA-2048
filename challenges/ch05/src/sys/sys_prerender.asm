;;==============================================================
;; Challenge 5 · Sistema de pre-render (componente SPRITE)
;; Prepara los sprites de las entidades en la OAM sombra, en RAM.
;; Copiar la sombra a la OAM no se hace aquí: es sys_render_update, que espera a VBLANK.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "sys/sys_render.inc"
INCLUDE "man/man_entity.inc"

SECTION "Prerender data", WRAM0
shadow_cursor::  DS 1   ;; Holds the LOW byte of the address inside shadow_oam where
                        ;; the next sprite should be written. shadow_oam is aligned
                        ;; (LOW(shadow_oam) = 0): this byte is the offset from its start

SECTION "System: prerender", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 06: `sys_prerender_one`
;; La implementas TÚ, en src/ej06.asm (etiqueta `ej06::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_prerender_one` y no necesita saber dónde está tu código.
sys_prerender_one::
   jp   go_ej06              ;; Salta al ejercicio 06 (ver main.asm)
   ds   21, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 07: `sys_prerender_update`
;; La implementas TÚ, en src/ej07.asm (etiqueta `ej07::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_prerender_update` y no necesita saber dónde está tu código.
sys_prerender_update::
   jp   go_ej07              ;; Salta al ejercicio 07 (ver main.asm)
   ds   26, $00              ;; Relleno: las demás rutinas conservan su dirección
