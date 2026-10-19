;;=============================================================================
;; constants.inc — Constantes compartidas del juego Pastor
;; Game Boy DMG · CPU SM83 · sintaxis RGBDS 0.9
;;=============================================================================
IF !DEF(CONSTANTS_INC)
DEF CONSTANTS_INC EQU 1

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
;; Se usa RSRESET/RB (como en la sesión 05.2) para que los índices se
;; numeren solos: añadir un tile nuevo es añadir una línea aquí y su dibujo allí.
RSRESET
DEF TILE_BLANK    RB 1   ;; blanco: fila del marcador. Va el 0 para que la VRAM a cero sea "vacía"
DEF TILE_GRASS    RB 1   ;; hierba del prado
DEF TILE_FENCE    RB 1   ;; valla (bloquea el paso)
DEF TILE_CORRAL   RB 1   ;; suelo de paja del corral
DEF TILE_SHEPHERD RB 1   ;; pastor
DEF TILE_SHEEP    RB 1   ;; oveja
DEF TILE_DIGIT_0  RB 10  ;; dígitos 0..9 consecutivos: tile = TILE_DIGIT_0 + valor
DEF TILE_FONT_A   RB 26  ;; letras A..Z consecutivas (ver text.inc)
DEF NUM_TILES     RB 0

;;-----------------------------------------------------------------------------
;; Entidades (ECS). Struct de 8 bytes, como en la sesión 05.2.
;; RSRESET/RB da el desplazamiento de cada campo: campo = base + E_CAMPO.
RSRESET
DEF E_ACTIVE      RB 1   ;; 0 = libre, 1 = en uso. DEBE ser el campo 0 (lo lee for_each)
DEF E_TYPE        RB 1   ;; TYPE_SHEPHERD / TYPE_SHEEP
DEF E_Y           RB 1   ;; fila en el tilemap
DEF E_X           RB 1   ;; columna en el tilemap
DEF E_TILE        RB 1   ;; tile con el que se dibuja
DEF E_OLD_Y       RB 1   ;; posición dibujada en pantalla: render la usa para borrar
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
DEF SHEEP_GRAZE_CHANCE   EQU 16  ;; si no huyen: probabilidad de paso al azar = N/256 por decisión

;; Marca de fin en las listas de datos (centinela): ninguna fila válida vale $FF
DEF END_OF_LIST   EQU $FF

;;-----------------------------------------------------------------------------
;; Escenas (índices de la tabla de scene_manager.asm)
DEF SCENE_TITLE   EQU 0
DEF SCENE_GAME    EQU 1
DEF SCENE_MESSAGE EQU 2

;; Qué hace START en la pantalla de mensaje
DEF AFTER_MESSAGE_NEXT_LEVEL EQU 0
DEF AFTER_MESSAGE_TITLE      EQU 1

;;-----------------------------------------------------------------------------
;; Niveles: cada entrada de level_table es mapa (dw), spawns (dw) y tiempo
;; (2 bytes BCD, el más significativo primero: $01, $20 = 120 s)
DEF NUM_LEVELS         EQU 3
DEF TIME_BYTES         EQU 2
DEF LEVEL_ENTRY_SIZE   EQU 4 + TIME_BYTES
DEF FRAMES_PER_SECOND  EQU 60
DEF WIN_DELAY_FRAMES   EQU 60   ;; tras encerrar la última oveja, 1 s antes del mensaje

;;-----------------------------------------------------------------------------
;; Puntuación (BCD: cada byte guarda 2 dígitos decimales, $0010 = 10 puntos)
DEF POINTS_PER_SHEEP   EQU $0010
DEF POINTS_PER_LEVEL   EQU $0100
DEF SCORE_BYTES        EQU 3    ;; 6 dígitos, el byte más significativo primero

;;-----------------------------------------------------------------------------
;; Marcador: bits de hud_dirty (qué hay que repintar este frame)
DEF HUDB_TIME  EQU 0
DEF HUDB_SCORE EQU 1
DEF HUDB_SHEEP EQU 2
DEF HUDF_ALL   EQU %00000111
DEF HUD_MAX_TILES EQU 16   ;; hueco reservado en la cola de render para el marcador y textos

ENDC
