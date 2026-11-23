# Challenge 9: motor de perceptrón para el Pong

Tu propio motor de Machine Learning en C++: lee las partidas que grabas jugando al Pong, prepara los datos, entrena dos perceptrones ("¿pulso arriba?" y "¿pulso abajo?") y escribe sus pesos para que el Pong los use como jugador.

Necesitas g++ 14 o posterior (C++23). El juego (`bin/pong`) funciona en Linux de 64 bits (x86-64) con glibc 2.36 o posterior.

## Qué hay aquí

```text
include/ml/ml.hpp   El motor: tipos y funciones. Cada función dice en qué ejercicio la programas
include/ml/rng.hpp  Generador de números aleatorios (el mismo del Pong) y shuffle
src/ejNN.cpp        Tus 12 ejercicios, uno por fichero
src/given.cpp       Rutinas ya resueltas (split, push_row)
src/train.cpp       El programa ./train: usa tus funciones de principio a fin
tests/              Las pruebas P1 y P2 de cada ejercicio
lib/libmlref.a      La solución de referencia, compilada (para las pruebas y para REF)
bin/pong            El juego
data/               Guarda aquí tus grabaciones
```

## Órdenes

```sh
make TEST=ej05      # compila y prueba el ejercicio 5: P1 y P2, con lo esperado y lo obtenido
make tests          # prueba los 12 ejercicios
make                # compila ./train con tus 12 ejercicios
make REF="05 09"    # compila ./train con la referencia en los ejercicios 5 y 9
                    # (para avanzar mientras los terminas)
make clean          # borra lo compilado
```

En las pruebas de un ejercicio, todas las demás funciones son las de la referencia: un ejercicio no depende de que los otros estén bien.

## Del juego a tu IA

```sh
# 1. Grabar: juega tú (pala izquierda, teclas A y Z) y se guarda cada frame
./bin/pong play -r expert:1 --out data/ana.csv --obs legacy

# 2. Entrenar: tus funciones procesan los datos y escriben los pesos
./train data/ana.csv data/luis.csv --name Azules -o azules.data

# 3. Probar: 100 partidos sin pantalla contra el experto 2, y uno para verlo
./bin/pong match -l perceptron:azules.data -r expert:2 -n 100 --headless
./bin/pong play -l perceptron:azules.data -r expert:2
```

`./train --help` muestra sus opciones (filtro de peloteos, fracción de test, semilla, costes...). `./bin/pong --help`, las del juego.

Si grabas varias veces en el mismo fichero, las partidas se añaden al final. Cada persona puede grabar en su propio fichero: `./train` los junta sin mezclar sus partidas.

## Créditos
- `bin/pong` es TeXtModE ML-PONG'26, basado en TeXtModE PONG, (c) 2001 Francisco J. Gallego-Durán y Eduardo Barredo Sánchez. Lleva incluida la biblioteca [ncurses](https://invisible-island.net/ncurses/), de Thomas E. Dickey y colaboradores. Licencia tipo MIT.
- (c) 2026 Francisco J. Gallego-Durán, (@FranGallegoBR, @ProfesorRetroman). Universidad de Alicante.
- Desarrollo asistido por Claudio (Claude Opus 5.5, de Anthropic).
