SECTION "Sound state", WRAM0
melody_timer: DS 1
melody_notes_left: DS 1
melody_ptr: DS 2

SECTION "Sound CODE", ROM0


sfx_init::
   ld a, $80
   ldh [$FF26], a           ;; NR52: APU encendida
   ld a, $77
   ldh [$FF24], a           ;; NR50: volumen izquierdo y derecho
   ld a, $11
   ldh [$FF25], a           ;; NR51: canal 1 en ambos lados
   ret


sfx_sheep_in::
   xor a
   ldh [$FF10], a           ;; NR10: sin barrido
   ld a, $A8
   ldh [$FF11], a           ;; NR11: pulso al 50%, duración corta
   ld a, $F2
   ldh [$FF12], a           ;; NR12: volumen alto con caída
   ld a, $00
   ldh [$FF13], a           ;; NR13: frecuencia baja
   ld a, $C7
   ldh [$FF14], a           ;; NR14: iniciar tono, activar longitud
   ret


music_level_clear_start::
   xor a
   ldh [$FF10], a           ;; NR10: sin barrido
   ld a, $80
   ldh [$FF11], a           ;; NR11: pulso al 50%
   ld a, $F2
   ldh [$FF12], a           ;; NR12: volumen alto con caída
   ld a, 5
   ld [melody_notes_left], a
   ld hl, melody_notes
   call music_play_note
   ret


music_update::
   ld a, [melody_timer]
   and a
   jr nz, .tick
   ld a, [melody_notes_left]
   and a
   ret z
   jr .next_note
.tick:
   ld hl, melody_timer
   dec [hl]
   ret nz
.next_note:
   ld a, [melody_notes_left]
   and a
   jr z, music_stop
   ld a, [melody_ptr]
   ld l, a
   ld a, [melody_ptr + 1]
   ld h, a
   call music_play_note
   ret


music_stop::
   xor a
   ld [melody_timer], a
   ld [melody_notes_left], a
   ldh [$FF12], a           ;; NR12: volumen 0
   ret


music_play_note:
   ld a, [hl+]
   ldh [$FF13], a           ;; NR13: frecuencia baja
   ld a, [hl+]
   or $C0                   ;; NR14: habilitar longitud y disparar
   ldh [$FF14], a
   ld a, [hl+]
   ld [melody_timer], a
   ld a, [melody_notes_left]
   dec a
   ld [melody_notes_left], a
   ld a, l
   ld [melody_ptr], a
   ld a, h
   ld [melody_ptr + 1], a
   ret


melody_notes:
   db $0C, $06, 12          ;; do 4
   db $73, $06, 12          ;; mi 4
   db $B2, $06, 12          ;; sol 4
   db $05, $07, 12          ;; do 5
   db $B2, $06, 18          ;; sol 4, nota final algo más larga
