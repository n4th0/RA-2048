;;==============================================================
;; Challenge 5 · Sistema del disparo
;; Solo hay UN disparo en todo el juego: no usa for_each.
;; Aquí está su estado (shot_entity, que solo toca este fichero) y lo que hace cada fotograma: comprobar que sigue ahí. Lo mueve la física, como al resto. Crear el disparo
;; (shot_spawn) es una regla del juego: está en scn/scn_game_rules.asm y usa sys_shot_spawn.
;;==============================================================
INCLUDE "man/man_entity.inc"
INCLUDE "gfx/gfx.inc"
INCLUDE "scn/scn_game.inc"

SECTION "Shot data", WRAM0
shot_entity::    DS 1                 ;; LOW byte of the shot's address (SHOT_NONE = there is none)
                                      ;; (the array is aligned: the high byte is always HIGH(entity_array))

SECTION "System: shot", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the system: there is no shot.
;; ❌ Modifies A
sys_shot_init::
   INCBIN "bin/sys_shot_init.bin"         ;; Rutina dada, en binario (6 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ⫷▬ HL = address of the shot's entity, Z = there is no shot
;; ❌ Modifies A, HL
sys_shot_get::
   INCBIN "bin/sys_shot_get.bin"          ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 04: `sys_shot_spawn`
;; La implementas TÚ, en src/ej04.asm (etiqueta `ej04::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_shot_spawn` y no necesita saber dónde está tu código.
sys_shot_spawn::
   jp   go_ej04              ;; Salta al ejercicio 04 (ver main.asm)
   ds   21, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Removes THE shot, if there is one: frees its entity and
;; leaves shot_entity at SHOT_NONE (= there is no shot).
;; ❌ May modify A, DE
sys_shot_destroy::
   INCBIN "bin/sys_shot_destroy.bin"      ;; Rutina dada, en binario (17 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 05: `sys_shot_update`
;; La implementas TÚ, en src/ej05.asm (etiqueta `ej05::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `sys_shot_update` y no necesita saber dónde está tu código.
sys_shot_update::
   jp   go_ej05              ;; Salta al ejercicio 05 (ver main.asm)
   ds   24, $00              ;; Relleno: las demás rutinas conservan su dirección
