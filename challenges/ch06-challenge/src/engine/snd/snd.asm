;;==============================================================
;; Challenge 6 · Sonido: la música y los efectos
;; La música la toca hUGEDriver (engine/lib/hUGEDriver) a partir de canciones hechas en hUGETracker.
;; Las canciones son datos en la ROM (assets/snd/song_*.asm). Una canción se empieza con
;; sound_play_song y suena sola: solo hay que llamar a sound_update UNA vez por frame, siempre
;; en el mismo sitio, para que el tempo sea constante. Los efectos de sonido (sfx) son 4 bytes
;; que se copian a los registros del canal 4 (assets/snd/snd_effects.asm).
;; ❌ No lo modifiques
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "engine/snd/snd.inc"

SECTION "Engine: sound", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turns the sound on: the 4 channels on both speakers, at maximum volume.
;; ⚠️ rAUDENA goes first: while the sound is off, the other registers ignore writes
;; ❌ Modifies A
sound_init::
   ld   a, AUDENA_ON            ;; \ Sound on
   ldh  [rAUDENA], a            ;; /

   ld   a, AUDTERM_ALL          ;; \ All the channels on both speakers
   ldh  [rAUDTERM], a           ;; /

   ld   a, AUDVOL_MAX           ;; \ Maximum volume
   ldh  [rAUDVOL], a            ;; /

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Starts a song from its beginning (the one that was playing stops). A song plays
;; forever, until another one starts. The channel 4 is left for the sound effects.
;; ⚠️ A scene that has no song of its own keeps the previous one playing
;; 📥 HL = song (its descriptor, in the ROM)
;; ❌ Modifies A, BC, DE, HL
sound_play_song::
   call hUGE_init               ;; The driver gets ready to play it from its first row

   ld   b, SFX_CHANNEL          ;; \ Mute the channel of the effects: the driver
   ld   c, 1                    ;; | leaves it alone (hUGE_init unmutes everything)
   jp   hUGE_mute_channel       ;; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Plays one tick of the music: it writes the registers of the channels 1 to 3 when
;; a new row begins. The main loop calls it once per frame, after the render.
;; ❌ Modifies A, BC, DE, HL
sound_update::
   jp   hUGE_dosound            ;; Tail-call: the driver returns for us

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Plays a sound effect on the channel 4 (the noise one). An effect is 4 bytes, the values
;; of the registers of the channel (assets/snd/snd_effects.asm). The last write starts the sound.
;; If another effect was sounding, this one replaces it.
;; 📥 HL = effect (4 bytes: LEN, ENV, POLY, GO)
;; ❌ Modifies A, HL
sound_play_effect::
   ld   a, [hl+]                ;; \ rAUD4LEN = LEN
   ldh  [rAUD4LEN], a           ;; /
   ld   a, [hl+]                ;; \ rAUD4ENV = ENV
   ldh  [rAUD4ENV], a           ;; /
   ld   a, [hl+]                ;; \ rAUD4POLY = POLY
   ldh  [rAUD4POLY], a          ;; /
   ld   a, [hl]                 ;; \ rAUD4GO = GO: bit 7 starts the sound
   ldh  [rAUD4GO], a            ;; /

   ret
