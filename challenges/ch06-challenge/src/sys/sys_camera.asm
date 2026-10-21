;;==============================================================
;; Challenge 6 · Sistema de cámara
;; El mundo (256 x 256 píxeles) es más grande que la pantalla (160 x 144). La cámara
;; es la esquina de arriba a la izquierda de lo que se ve: sigue a una entidad
;; (el héroe) y no sale del mundo. Su posición (cam_x, cam_y) la usa sys_prerender
;; para saber dónde dibujar cada sprite, y sys_render para mover el background (scroll).
;; Esos datos son PRIVADOS de este sistema: los demás los piden con sys_camera_get.
;;==============================================================
INCLUDE "engine/hardware.inc"
INCLUDE "man/man_entity.inc"
INCLUDE "man/man_map.inc"

;; The entity is kept in the middle of the screen: the camera is its position minus
;; the distance from the corner of the image to the middle of the screen. The camera
;; can go from 0 to the last position where the screen is still inside the world
;; (the world is MAP_PIXELS = 256 pixels long in both axes).
DEF CAMERA_OFFSET_X = SCREEN_WIDTH / 2 - IMAGE_WIDTH / 2    ;; 72: the middle of the image
DEF CAMERA_OFFSET_Y = SCREEN_HEIGHT / 2 - IMAGE_HEIGHT / 2   ;; 64

SECTION "Camera data", WRAM0
cam_x::           DS 1                 ;; world X of the left of the screen (0-96). PRIVATE: use sys_camera_get
cam_y::           DS 1                 ;; world Y of the top of the screen (0-112). PRIVATE: use sys_camera_get

SECTION "System: camera", ROM0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initializes the camera at the top left corner of the world.
;; ❌ Modifies A
sys_camera_init::
   INCBIN "bin/sys_camera_init.bin"       ;; Rutina dada, en binario (8 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Where the camera is: the world position of the top left corner of the screen.
;; ⫷▬ RETURNS: B = camera X, C = camera Y
;; ❌ Modifies A, BC
sys_camera_get::
   INCBIN "bin/sys_camera_get.bin"        ;; Rutina dada, en binario (9 bytes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 02: `camera_axis`
;; La implementas TÚ, en src/ej02.asm (etiqueta `ej02::`). Aquí solo hay un salto:
;; el resto del proyecto llama a `camera_axis` y no necesita saber dónde está tu código.
camera_axis::
   jp   go_ej02              ;; Salta al ejercicio 02 (ver main.asm)
   ds   9, $00              ;; Relleno: las demás rutinas conservan su dirección

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Places the camera so that an entity is in the middle of the screen, as far as
;; the borders of the world allow.
;; 📥 DE = the entity to follow
;; ❌ Modifies A, BC, HL
sys_camera_update::
   INCBIN "bin/sys_camera_update.bin"     ;; Rutina dada, en binario (28 bytes)
