;;==============================================================
;; Challenge 5 · Sistema de colisiones (componente COLLIDER)
;; Una sonda contra todas las entidades, filtrando por KIND. El sistema no sabe qué
;; choca con qué ni qué causa cada colisión: eso son reglas del juego (game_handle_collisions).
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Collision data", WRAM0
collision_probe::DS 2                 ;; entity that is being tested against the rest
collision_mask:: DS 1                 ;; kinds the probe collides with
collision_hits:: DS 1                 ;; collisions found in this pass

SECTION "System: collision", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 09: `sys_collision_overlaps`
;; La implementas TÚ, en src/ej09.asm (etiqueta `ej09::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_collision_overlaps` y no necesita saber dónde está tu código.
sys_collision_overlaps::
   jp   go_ej09              ;; Salta al ejercicio 09 (ver main.asm)
   ds   26, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 10: `sys_collision_one`
;; La implementas TÚ, en src/ej10.asm (etiqueta `ej10::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_collision_one` y no necesita saber dónde está tu código.
sys_collision_one::
   jp   go_ej10              ;; Salta al ejercicio 10 (ver main.asm)
   ds   36, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks ONE probe against ALL the entities: it is the 'update' of this system.
;; Unlike the other systems, it needs context (the probe and the kinds it collides
;; with): that is why it has parameters. The game calls it once per probe.
;; The probe must have the COLLIDER component too: an entity that has lost
;; it (an exploding ship) collides with nothing.
;; 📥 INPUT:   HL: the probe (entity), B: mask of the kinds it collides with
;; ⫷▬ RETURNS: A: number of entities that collided (and have been freed)
;;             Z if there were none, NZ if there was at least one
;; ❌ May modify A, BC, DE, HL
sys_collision_update::
   INCBIN "bin/sys_collision_update.bin"  ;; Rutina dada, en binario (31 bytes)
