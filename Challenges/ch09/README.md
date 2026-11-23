# Challenge 5 · Desafío

## Qué tocar

- `src/ejNN.asm`: tu código. Uno por ejercicio.
- `src/main.asm`: solo la línea `DEF TEST EQUS "..."`.
- `src/chcode/`: no tocar.

## BGB

- Activa *Options* (F11) → *Exceptions* → **break on ld b,b (40h)**.

## Depura el ejercicio XX

1. Copia tu código del papel a `ejXX.asm`, **tal cual**. Ejercicios de corregir (1 y 3): no hace falta, el código con errores ya está en su `ejXX.asm`.
2. Cada cambio posterior, con su comentario `;; FIX <tipo><nº>: <motivo>`.
3. En `main.asm`: `test_ejXX`. Ejecuta `make`.
4. Abre `game.gb` en BGB y pulsa F9. Cada parada en `ld b, b` es un caso de prueba.
5. Compara CPU y MEM con el RESULTADO ESPERADO de `ejXX.asm`. F9 pasa al siguiente.
6. Rellena el resumen final de `ejXX.asm`.

## El juego completo

`DEF TEST EQUS "game"` usa TODOS tus ejercicios: solo funciona cuando están todos. Si funciona, hay **bonus**.

## Si un ejercicio no ensambla

Renómbralo a `ejXX.asm.no` y prueba el resto.

Ejercicios de corregir (1 y 3): no ensamblan hasta que corrijas sus errores de tipo N y S. Para probar otro ejercicio antes, renombra sus ficheros a `ejXX.asm.no` y devuélvele el nombre al terminar.

## Ejercicios que usan otros

Las pruebas de un ejercicio usan una versión del proyecto de las rutinas de las que depende. Un fallo en otro ejercicio no afecta a la prueba del tuyo.

## Los ejercicios

| Ej. | Rutinas | Etiquetas |
| :-: | --- | --- |
| 1 | `man_entity_alloc` | `ej01` |
| 2 | `man_entity_for_each` | `ej02` |
| 3 | `sys_physics_one` | `ej03` |
| 4 | `sys_shot_spawn` | `ej04` |
| 5 | `sys_shot_update` | `ej05` |
| 6 | `sys_prerender_one` | `ej06` |
| 7 | `sys_prerender_update` | `ej07` |
| 8 | `sys_render_update` | `ej08` |
| 9 | `sys_collision_overlaps` | `ej09` |
| 10 | `sys_collision_one` | `ej10` |
| 11 | `scene_menu_update`, `scene_gameover_update` | `ej11a`, `ej11b` |
| 12 | `game_handle_collisions` | `ej12` |

## Entrega

`make cleanall` antes de comprimir el proyecto.
