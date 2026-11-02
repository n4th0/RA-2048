# Pastor

Pastor es un juego desarrollado en ensamblador (CPU SM83 / Z80) para la consola Game Boy (DMG/Color) utilizando el framework GBTelera. Este proyecto ha sido creado para la jam GBRetroDev 2026.

---

## Descripcion del juego

En Pastor, encarnas a un perro pastor cuya mision es guiar y reunir a todas las ovejas dispersas por el campo para encerrarlas a salvo dentro del corral antes de que se agote el tiempo limite[cite: 9].

A medida que avanzas por los distintos niveles, el recorrido se complica con laberintos de vallas y la aparicion de lobos hambrientos[cite: 9]. Los lobos se mueven por el prado asustando a las ovejas, por lo que tendras que actuar con rapidez y trazar la mejor estrategia para conducirlas al corral[cite: 9].

---

## Controles

- Cruceta (D-Pad): Mover al pastor por la pantalla (Arriba, Abajo, Izquierda, Derecha)[cite: 9].
- Boton START: Pausar la partida durante el nivel / Aceptar o saltar pantallas de mensajes[cite: 9].

---

## Caracteristicas principales

- 5 Niveles con dificultad progresiva y mapa con vallas y zona de corral.
- Sistema de IA y comportamientos:
  - Las ovejas pastan de forma aleatoria y huyen al detectar la presencia del pastor o de los lobos.
  - Los lobos patrullan el campo alterando el movimiento del rebaño.
- Musica y efectos sonoros chiptune.
- Graficos estilo DMG adaptados a la pantalla de 20x18 tiles.
- Sistema de puntuacion y bonificacion por tiempo restante al superar el nivel.

---

## Compilacion

Para compilar el proyecto en Fedora, abre una terminal en la subcarpeta del juego (`pastor/`) y ejecuta:

```bash
make

gbt_game.gb
