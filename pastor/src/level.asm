;;=============================================================================
;; level.asm — Carga de niveles y copia del mapa en WRAM
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

;; Copia del nivel actual. Las colisiones se consultan aquí y no en VRAM:
;; la VRAM no siempre se puede leer (la PPU la bloquea mientras dibuja),
;; y además nos dice qué tile de fondo repintar al mover una entidad.
SECTION "Level map", WRAM0
level_map:: DS LEVEL_SIZE

SECTION "Level code", ROM0

;;-----------------------------------------------------------------------------
;; level_load: carga un nivel en la copia de WRAM y en el tilemap $9800.
;; Escribe 360 bytes en VRAM, que no caben en un VBLANK:
;; LLAMAR CON LA PANTALLA APAGADA (lcd_off).
;; 📥 HL = dirección del nivel en ROM (LEVEL_SIZE bytes)
;; Modifica: A, F, BC, DE, HL
level_load::
   ;; 1) Copia completa a WRAM (es contigua, basta un memcpy)
   push hl                  ;; memcpy avanza HL: guardamos el inicio para el paso 2
   ld de, level_map
   ld bc, LEVEL_SIZE
   call memcpy
   pop hl

   ;; 2) Copia al tilemap fila a fila: tras cada fila de 20 tiles
   ;;    hay que saltar los 12 que no se ven
   ld de, _SCRN0
   ld c, SCREEN_H           ;; C = filas que faltan
.row:
   ld b, SCREEN_W           ;; B = columnas que faltan en esta fila
.col:
   ld a, [hl+]
   ld [de], a
   inc de
   dec b
   jr nz, .col

   ld a, e                  ;; DE += 12: suma de 16 bits con add + adc (sesión 03.1)
   add MAP_STRIDE - SCREEN_W
   ld e, a
   ld a, d
   adc 0                    ;; la parte alta recibe el acarreo
   ld d, a
   dec c
   jr nz, .row
   ret

;;-----------------------------------------------------------------------------
;; level_tile_at: tile de fondo de la casilla (B, C), leído de la copia en WRAM.
;; Dirección = level_map + fila * 20 + columna (fila * 20 = fila * 16 + fila * 4)
;; `add hl, hl` es HL = HL + HL, es decir, multiplicar por 2.
;; 📥 B = fila, C = columna
;; 📤 A = tile, HL = su dirección en level_map
;; Modifica: A, F, DE, HL
level_tile_at::
   ld h, 0
   ld l, b
   add hl, hl
   add hl, hl               ;; HL = fila * 4
   ld d, h
   ld e, l
   add hl, hl
   add hl, hl               ;; HL = fila * 16
   add hl, de               ;; HL = fila * 20
   ld d, 0
   ld e, c
   add hl, de               ;; + columna
   ld de, level_map
   add hl, de
   ld a, [hl]
   ret

;;-----------------------------------------------------------------------------
;; level_is_blocked: ¿se puede pisar la casilla (B, C)?
;; Solo se pisa hierba o corral y si no hay otra entidad encima.
;; No comprueba límites: confía en que todo nivel está rodeado de valla.
;; 📥 B = fila, C = columna
;; 📤 carry a 1 si está bloqueada, carry a 0 si está libre
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
   jp man_entity_at         ;; tail-call: su carry es nuestra respuesta
