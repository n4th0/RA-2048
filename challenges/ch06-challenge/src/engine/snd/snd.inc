;;==============================================================
;; Challenge 6 · Sonido: estructura
;; ❌ No lo modifiques
;;==============================================================
IF !DEF(SND_INC)
DEF SND_INC = 1

;; The music uses the channels 1 and 2 (pulse) and 3 (wave). The channel 4 (noise) is
;; left for the sound effects: the music driver does not touch it (it is "muted").
;; It is the number that hUGE_mute_channel expects: 0 is the channel 1, 3 is the channel 4.
DEF SFX_CHANNEL = 3

ENDC
