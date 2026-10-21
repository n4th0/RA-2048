# CHELDA · Desafío del Challenge 6

Un mini-Zelda visto desde arriba para la Game Boy, en ensamblador (RGBDS) con el framework GBTelera. En este proyecto escribes las rutinas de los ejercicios y las compruebas una a una. Si con todas ellas el juego completo funciona, **bonus +1 B**.

## Qué tocar

- `src/ej01.asm` … `src/ej12.asm`: tu código. Uno por ejercicio. Los de **corregir** (1 y 12) empiezan como `ej01.asm.no` y `ej12.asm.no`: renómbralos cuando vayas a empezar.
- `src/main.asm`: solo las líneas `DEF` de arriba (`TEST`).
- `src/chcode/`: no tocar (pruebas y código del proyecto).
- El resto de `src/` es el juego. Lo que ya está hecho va en binario (`src/bin/`) y sus **contratos** están en los comentarios. Lo que te dejamos como código para que lo leas: `main.asm` (con `init_console`), las rutinas de escena (`scene_game_*`, `scene_menu_*`, `scene_gameover_*`, `scene_win_*` y `scene_text_start`), `memory.asm`, `screen.asm`, `rng.asm`, `oam.asm`, `sys_selfdestroy.asm` y el sonido (`snd.asm`).

## Cómo funciona

Cada ejercicio vive en su sitio (por ejemplo, `sys_ai_one` en `src/sys/sys_ai.asm`), pero allí solo hay un salto. Tu código va en `src/ejNN.asm`.

- **Completar o implementar**: escribe lo que falta donde dice `◉◉YOUR CODE◉◉`.
- **Corregir**: el código con errores ya está en el fichero. Encuéntralos y arréglalos.

## Prueba un ejercicio (P1 y P2)

1. En `main.asm`: `DEF TEST EQUS "test_ej05"`. Ejecuta `make`.
2. Abre `game.gb` en BGB y pulsa F9. Cada parada en un `ld b, b` es un caso (P1, P2).
3. Compara CPU y MEM con el RESULTADO ESPERADO del final de `ej05.asm`. F9 pasa al siguiente.

Las pruebas usan las rutinas del proyecto para todo lo demás: un fallo en otro ejercicio no afecta al tuyo.

## Prueba el juego completo

Cuando estén hechos todos los ejercicios (con los de corregir renombrados a `.asm`):

1. En `main.asm`: `DEF TEST EQUS "game"`.
2. `make` y abre `game.gb` en BGB.

Después de tocar un `.inc` haz `make clean`: el Makefile no vigila los `.inc`.

## BGB

- Activa *Options* (F11) → *Exceptions* → **break on ld b,b (40h)**.
- Símbolos: la primera vez, `ln -s obj/game.sym game.sym` en la carpeta del proyecto.

## Los ejercicios

| Ej. | Rutinas | Etiquetas |
| :-: | --- | --- |
| 1 | `dma_init` | `ej01` |
| 2 | `camera_axis` | `ej02` |
| 3 | `sys_render_scroll` | `ej03` |
| 4 | `map_tile_address` | `ej04` |
| 5 | `hud_show`, `hud_draw_hearts` | `ej05a`, `ej05b` |
| 6 | `game_enemies_spawn` | `ej06` |
| 7 | `portal_spawn` | `ej07` |
| 8 | `sys_ai_choose` | `ej08` |
| 9 | `world_to_oam` | `ej09` |
| 10 | `sys_prerender_one` | `ej10` |
| 11 | `sys_animation_one` | `ej11` |
| 12 | `sys_animation_image` | `ej12` |

## Si un ejercicio no ensambla

Renómbralo a `ejXX.asm.no` y prueba el resto. Para probar el ejercicio `XX`, `TEST` debe ser `"test_ejXX"` y ese fichero tiene que llamarse `ejXX.asm`.

## Entrega

`make clean` antes de comprimir: no entregues `obj/`, `game.gb`, `game.sym` ni `game.sav`.

## Licencias y créditos
Este proyecto usa trabajo de otras personas. Aunque alguna licencia no obligue a citarlo, **lo citamos**: citar bien lo que usas es parte del trabajo, y te enseña a hacerlo con lo que uses tú en tus proyectos (qué es, quién lo hizo, de dónde lo has sacado y bajo qué licencia).

| Qué | Quién | Licencia | Dónde se usa |
| --- | --- | --- | --- |
| **hUGEDriver**, el driver que toca la música | Nick Faro (*SuperDisk*). [github.com/SuperDisk/hUGEDriver](https://github.com/SuperDisk/hUGEDriver) | Dominio público (dedicado por su autor) | `src/engine/lib/hUGEDriver/` (copia del commit `d6863d2`, sin modificar) |
| **hUGETracker**, el programa para componer la música que toca ese driver | Nick Faro (*SuperDisk*). [github.com/SuperDisk/hUGETracker](https://github.com/SuperDisk/hUGETracker) | Dominio público (dedicado por su autor) | Formato de las canciones de `src/assets/snd/` (el que exporta como «RGBDS .asm») |
| **hardware.inc**, los nombres de los registros de la consola (viene con el driver) | Comunidad [gbdev](https://github.com/gbdev/hardware.inc) | CC0 1.0 | `src/engine/lib/hUGEDriver/include/hardware.inc` |
| **Tabla de notas** del driver | Nick Faro, generada a partir de [devrs.com/gb/files/sndtab.html](http://www.devrs.com/gb/files/sndtab.html) | Dominio público (con el driver) | `src/engine/lib/hUGEDriver/include/hUGE_note_table.inc` |
| **RGBDS**, el ensamblador y el enlazador | Comunidad [gbdev](https://github.com/gbdev/rgbds) | MIT | Herramienta con la que se compila |
| **GBTelera**, el framework de desarrollo | ronaldo / Cheesetea / ByteRealms (@FranGallegoBR), 2024 | MIT (el aviso está en la cabecera de cada fichero) | `Makefile`, `cfg/` y `src/header.asm` |
| **Xorshift de 16 bits**, el generador de números aleatorios | George Marsaglia | Algoritmo descrito en *Xorshift RNGs* (2003) | `src/engine/rng.asm` |
| **Pan Docs**, la documentación técnica de la consola | Comunidad [gbdev](https://gbdev.io/pandocs/) | CC0 1.0 | Referencia citada en `src/header.asm` |

Los gráficos, la tipografía de 5×7 píxeles (la misma del Challenge 5) y las seis canciones de `src/assets/snd/` son originales de este proyecto.

**Cuando uses música, gráficos o código ajenos en tu proyecto**, apunta en tu `README.md` qué es, quién lo hizo, el enlace de donde lo has sacado y su licencia. Si no sabes cuál es la licencia, no lo uses hasta saberlo. Si la licencia pide citar, cita.
