;;=============================================================================
;; constants.inc — Constantes compartidas del juego Pastor
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;
;; Inclúyelo UNA vez por fichero .asm (con DEF no se puede definir dos veces).
;;=============================================================================

;;-----------------------------------------------------------------------------
;; Pantalla y tilemap
;; El tilemap mide 32x32 tiles, pero solo se ven 20x18. Por eso al pintar
;; una fila hay que saltar MAP_STRIDE - SCREEN_W tiles para llegar a la siguiente.
DEF SCREEN_W   EQU 20
DEF SCREEN_H   EQU 18
DEF MAP_STRIDE EQU 32
DEF LEVEL_SIZE EQU SCREEN_W * SCREEN_H   ;; 360 bytes por nivel

;;-----------------------------------------------------------------------------
;; Índices de tile. El orden DEBE coincidir con el de tiles.asm.
;; RSRESET/RB (sesión 05.2) numera solos los índices: añadir un tile es
;; añadir una línea aquí y su dibujo en tiles.asm.
RSRESET
DEF TILE_BLANK    RB 1   ;; blanco (fila del marcador y fondo de los textos)
DEF TILE_GRASS    RB 1   ;; hierba del prado
DEF TILE_FENCE    RB 1   ;; valla (bloquea el paso)
DEF TILE_CORRAL   RB 1   ;; suelo de paja del corral
DEF TILE_SHEPHERD RB 1   ;; pastor
DEF TILE_SHEPHERD_STEP RB 1 ;; pastor con las piernas en otra posición
DEF TILE_SHEEP    RB 1   ;; oveja
DEF TILE_SHEEP_HAPPY RB 1 ;; oveja recién encerrada / celebración
DEF TILE_DIGIT_0  RB 10  ;; dígitos 0..9 seguidos: tile = TILE_DIGIT_0 + valor
DEF TILE_FONT_A   RB 26  ;; letras A..Z seguidas (ver charmap.inc)
DEF NUM_TILES     RB 0

;;-----------------------------------------------------------------------------
;; Entidades (ECS). Struct de 8 bytes, como en la sesión 05.2.
;; Campo = base de la entidad + desplazamiento.
RSRESET
DEF E_ACTIVE      RB 1   ;; 0 = libre, 1 = en uso. Tiene que ser el campo 0
DEF E_TYPE        RB 1   ;; TYPE_SHEPHERD / TYPE_SHEEP / TYPE_SHEEP_PENNED
DEF E_Y           RB 1   ;; fila en el tilemap
DEF E_X           RB 1   ;; columna en el tilemap
DEF E_TILE        RB 1   ;; tile con el que se dibuja
DEF E_OLD_Y       RB 1   ;; dónde está dibujada ahora (para borrarla al moverse)
DEF E_OLD_X       RB 1
DEF E_COOLDOWN    RB 1   ;; frames que faltan para poder dar el siguiente paso
DEF SIZEOF_ENTITY RB 0   ;; = 8

;; 16 * 8 = 128 bytes: caben en un bloque de 256 alineado (ver entity_manager.asm)
DEF MAX_ENTITIES  EQU 16

;; Tipos de entidad
DEF TYPE_SHEPHERD     EQU 0
DEF TYPE_SHEEP        EQU 1   ;; suelta por el prado
DEF TYPE_SHEEP_PENNED EQU 2   ;; ya en el corral: solo se mueve sobre suelo de corral

;; Velocidad: un paso cada N frames (60 frames = 1 s)
DEF SHEPHERD_STEP_FRAMES EQU 6
DEF SHEEP_STEP_FRAMES    EQU 10  ;; más lentas que el pastor, si no no hay quien las alcance

;; Comportamiento de las ovejas
DEF SHEEP_SCARE_DISTANCE EQU 3   ;; huyen si |dx| + |dy| <= esto
DEF SHEEP_GRAZE_CHANCE   EQU 16  ;; si no huyen: paso al azar si el número aleatorio < esto (16 de 256)

;; Marca de fin de las listas (centinela, sesión 03.1): ninguna fila vale $FF
DEF END_OF_LIST   EQU $FF

;;-----------------------------------------------------------------------------
;; Mando: bits de joypad_dpad y joypad_buttons, como en la sesión 02.2
;; (1 = pulsado; joypad.asm ya los da la vuelta)
DEF PAD_RIGHT  EQU 0
DEF PAD_LEFT   EQU 1
DEF PAD_UP     EQU 2
DEF PAD_DOWN   EQU 3
DEF BTN_A      EQU 0
DEF BTN_B      EQU 1
DEF BTN_SELECT EQU 2
DEF BTN_START  EQU 3

;;-----------------------------------------------------------------------------
;; Escenas (índices de la tabla de scene_manager.asm)
DEF SCENE_TITLE   EQU 0
DEF SCENE_GAME    EQU 1
DEF SCENE_MESSAGE EQU 2

;; Qué hace START en la pantalla de mensaje
DEF AFTER_MESSAGE_NEXT_LEVEL EQU 0
DEF AFTER_MESSAGE_TITLE      EQU 1

;;-----------------------------------------------------------------------------
;; Números de varias cifras: UN DÍGITO POR BYTE (0..9), el más alto primero.
;; Así sumar es "si pasa de 9, resto 10 y me llevo 1", y pintar un dígito
;; es sumarle TILE_DIGIT_0.
DEF SCORE_DIGITS EQU 6   ;; puntos: 000000 .. 999999
DEF TIME_DIGITS  EQU 3   ;; segundos: 000 .. 999

;;-----------------------------------------------------------------------------
;; Niveles: cada entrada de level_table es mapa (dw), spawns (dw) y tiempo
;; (TIME_DIGITS bytes, p. ej. db 1, 2, 0 = 120 s)
DEF NUM_LEVELS         EQU 5
DEF LEVEL_ENTRY_SIZE   EQU 2 + 2 + TIME_DIGITS
DEF FRAMES_PER_SECOND  EQU 60
DEF WIN_DELAY_FRAMES   EQU 60   ;; tras encerrar la última oveja, 1 s antes del mensaje

;; Hueco de la cola de render reservado para el marcador y los textos
DEF HUD_MAX_TILES EQU 16
