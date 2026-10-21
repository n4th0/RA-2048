;;==============================================================
;; Challenge 6 · Efectos de sonido
;; Cada efecto son 4 bytes: lo que se escribe en los registros del canal 4 (ruido).
;; Se tocan con sound_play_effect.
;;==============================================================
SECTION "Sound effects", ROM0

;; The 4 bytes of an effect, in the order they are written:
;;   LEN   rAUD4LEN   Length of the sound. Only used if bit 6 of GO is 1
;;   ENV   rAUD4ENV   Volume (bits 7-4: 0 is silence, 15 is the loudest) and how it changes:
;;                    bit 3 = 0 fades out, bits 2-0 = speed (1 is fast, 7 is slow, 0 stays)
;;   POLY  rAUD4POLY  The noise: bits 7-4 and 2-0 make it lower when they are bigger,
;;                    bit 3 = 1 makes it more "buzzy" than "hissy"
;;   GO    rAUD4GO    Bit 7 = 1 starts the sound, bit 6 = 1 stops it when LEN ends

;; The sword swings: a short, light hiss
SfxSword::
   DB $00, $A1, $41, $80

;; An enemy is defeated: a "pop" that fades out
SfxDefeat::
   DB $00, $C2, $6B, $80

;; The hero is hurt: a low rumble
SfxHurt::
   DB $00, $E2, $72, $80
