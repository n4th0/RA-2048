;;==============================================================
;; Challenge 6 · Gestor del mapa (Map Manager)
;; El mapa del nivel actual: dibujarlo y saber qué hay en cada punto del mundo.
;; Solo sabe de tiles: no sabe qué entidades hay ni quién pregunta.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "assets/gfx/gfx.inc"
INCLUDE "man/man_map.inc"

SECTION "Map data", WRAM0
map_current::     DS 2                 ;; address (in ROM) of the map of the current level

SECTION "Map manager", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads a map: remembers it and draws it in the background of the screen.
;; 📥 HL = the map (MAP_SIZE tiles)
;; ⚠️ The screen must be OFF
;; ❌ Modifies A, BC, DE, HL
map_load::
   INCBIN "bin/map_load.bin"              ;; Rutina dada, en binario (17 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 04: `map_tile_address`
;; La implementas TÚ, en src/ej04.asm (etiqueta `ej04::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `map_tile_address` y no necesita saber dónde está tu código.
map_tile_address::
   jp   go_ej04              ;; Salta al ejercicio 04 (ver main.asm)
   ds   19, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Is the point solid? A tile is solid if it is TILE_FIRST_SOLID or higher:
;; the tiles are ordered in the tile block so that one comparison decides it.
;; 📥 D = Y, E = X (pixels of the world)
;; ⫷▬ NZ, the point is in a solid tile
;;    Z,  it is free
;; ❌ Modifies A, HL
map_is_solid_at::
   INCBIN "bin/map_is_solid_at.bin"       ;; Rutina dada, en binario (31 bytes)
