;;==============================================================
;; Challenge 5 · Sistema de aparición de asteroides
;; De vez en cuando crea un asteroide. Cae recto, o en diagonal; las diagonales pueden
;; entrar por arriba o por los lados (hasta media pantalla), y siempre se apuntan a un
;; punto de la zona del jugador: llegan a su fila.
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Spawn data", WRAM0
spawn_timer::    DS 1                 ;; frames until the next asteroid

SECTION "System: spawn", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the system: the first asteroid comes in SPAWN_FIRST_FRAMES frames.
;; ❌ Modifies A
sys_spawn_init::
   INCBIN "bin/sys_spawn_init.bin"        ;; Rutina dada, en binario (6 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Every so often, creates an asteroid. It falls in one of these ways (bits of D):
;;  - STRAIGHT: random column (16-143), speed 1 or 2.
;;  - DIAGONAL (speed DIAGONAL_VY, VX = +1 or -1). It is AIMED: it will arrive at the
;;    ship's row at a column inside the player's zone, so it is a threat. Where it starts:
;;      * From the TOP: a random target column (16-143). It takes SHIP_Y / DIAGONAL_VY
;;        frames to reach the ship's row, and in them it moves DIAGONAL_SHIFT sideways, so
;;        it starts that far from the target: on the left (moving right) if the target
;;        is on the right half, and the other way round if not.
;;      * From a SIDE: just outside the left or the right edge, at a random height from
;;        the top to the middle of the screen. The lower it starts, the less it falls
;;        and the sooner it gets to the player's row: it lands in the central zone.
;; Starting at different places and heights makes them less predictable.
;; If there is no free entity, it does nothing.
;; ❌ Modifies A, BC, DE, HL
sys_spawn_update::
   INCBIN "bin/sys_spawn_update.bin"      ;; Rutina dada, en binario (130 bytes)
