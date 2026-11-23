# Motor de Machine Learning del Challenge 9
#
#   make                  compila ./train con tus 12 ejercicios
#   make REF="05 09"      compila ./train usando la solución de referencia en
#                         los ejercicios 5 y 9 (para avanzar sin tenerlos)
#   make TEST=ej05        compila y ejecuta las pruebas P1 y P2 del ejercicio 5
#   make tests            ejecuta las pruebas de los 12 ejercicios
#   make clean            borra lo compilado
#
# Cada ejercicio se compila por separado (src/ejNN.cpp): si uno tiene un
# error, los demás se pueden seguir probando. En las pruebas de un ejercicio,
# todas las demás funciones son las de la solución de referencia (lib/libmlref.a):
# así un ejercicio no depende de que los otros estén bien.

CXX      ?= g++
# -D_GLIBCXX_ASSERTIONS: un índice fuera de un vector para el programa con un mensaje,
# en vez de leer o escribir memoria que no es suya
CXXFLAGS := -std=c++23 -O2 -Wall -Wextra -Wpedantic -Iinclude -Itests -D_GLIBCXX_ASSERTIONS
EJS      := 01 02 03 04 05 06 07 08 09 10 11 12
REF      ?=
MINE     := $(filter-out $(REF),$(EJS))
REFLIB   := lib/libmlref.a

# train se enlaza siempre: así, make REF="..." usa la lista de REF que le des
.PHONY: all tests clean run-test train
.SECONDARY:

ifdef TEST
all: run-test
else
all: train
endif

train: build/train.o build/given.o $(MINE:%=build/ej%.o) $(REFLIB)
	$(CXX) -o $@ $^

run-test: build/test_$(TEST)
	@./build/test_$(TEST)

build/test_ej%: build/tests/test_ej%.o build/ej%.o build/given.o $(REFLIB)
	$(CXX) -o $@ $^

tests:
	@ok=0; for e in $(EJS); do \
	   if $(MAKE) -s build/test_ej$$e >/dev/null 2>&1; then \
	      if ./build/test_ej$$e >/dev/null; then echo "ej$$e: OK"; ok=$$((ok+1)); \
	      else echo "ej$$e: falla (make TEST=ej$$e para ver el detalle)"; fi; \
	   else echo "ej$$e: no compila (make TEST=ej$$e para ver el error)"; fi; \
	done; echo "Ejercicios correctos: $$ok de 12"

build/%.o: src/%.cpp include/ml/ml.hpp include/ml/rng.hpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

build/tests/%.o: tests/%.cpp tests/test.hpp include/ml/ml.hpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf build train
