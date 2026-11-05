INCLUDE "hardware.inc"
INCLUDE "constants.inc"

;; la VRAM no siempre se puede leer (la PPU la bloquea mientras dibuja),
SECTION "Level map", WRAM0
level_map:: DS LEVEL_SIZE

SECTION "Level code", ROM0

;; level_load: carga un nivel en la copia de WRAM y en el tilemap $9800.
;; Escribe 360 bytes en VRAM, que no caben en un VBLANK:
;; llamar con la pantalla apagada (lcd_off).
;; HL = dirección del nivel en ROM (LEVEL_SIZE bytes)
;; Modifica: A, F, BC, DE, HL
level_load::
   push hl                  
   ld de, level_map
   ld bc, LEVEL_SIZE
   call memcpy
   pop hl

   ld de, _SCRN0
   ld c, SCREEN_H           
.row:
   ld b, SCREEN_W           
.col:
   ld a, [hl+]
   ld [de], a
   inc de
   dec b
   jr nz, .col

   ld a, e                  ;; DE += 12
   add MAP_STRIDE - SCREEN_W
   ld e, a
   ld a, d
   adc 0                    
   ld d, a
   dec c
   jr nz, .row
   ret

;; level_tile_at: tile de fondo de la casilla (B, C), leído de la copia en WRAM.
;; Dirección = level_map + fila * 20 + columna (fila * 20 = fila * 16 + fila * 4)
;; `add hl, hl` es HL = HL + HL, multiplicar por 2.
;; B = fila, C = columna
;; A = tile, HL = su dirección en level_map
;; Modifica: A, F, DE, HL
level_tile_at::
   ld h, 0
   ld l, b
   add hl, hl
   add hl, hl               
   ld d, h
   ld e, l
   add hl, hl
   add hl, hl               
   add hl, de               
   ld d, 0
   ld e, c
   add hl, de               
   ld de, level_map
   add hl, de
   ld a, [hl]
   ret

;; level_is_blocked: ¿se puede pisar la casilla (B, C)?
;; Solo se pisa hierba o corral y si no hay otra entidad encima.
;; No comprueba límites
;; B = fila, C = columna
;; carry a 1 si está bloqueada, carry a 0 si está libre
;; Modifica: A, F, DE, HL
level_is_blocked::
   call level_tile_at
   cp TILE_GRASS
   jr z, .check_entities
   cp TILE_CORRAL
   jr z, .check_entities
   scf                      ;; valla, marcador o cualquier otro tile: bloquea
   ret
.check_entities:
   jp man_entity_at         ;; tail-call
