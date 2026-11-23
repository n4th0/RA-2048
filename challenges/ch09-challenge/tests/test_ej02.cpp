#include <stdexcept>
#include "test.hpp"
using namespace test;

int main() {
   auto t = table("match;action;f1;f2\n1;-1;0.5;2\n1;0;;-1\n2;1;-3;4\n2;-1;1;\n");

   std::println("P1: entradas f1 y f2, problema \"arriba\"; las filas 2 y 4 tienen una "
                "entrada vacía");
   auto d = ml::make_dataset(t, {"f1", "f2"}, -1);
   check("X", d.X, std::vector<ml::Vec>{{1, 0.5, 2}, {1, -3, 4}});
   check("y", d.y, std::vector<int>{+1, -1});
   check("match", d.match, std::vector<int>{1, 2});

   std::println("P2: solo f2, problema \"abajo\" (la fila 4 tiene f2 vacía), y una "
                "columna que no existe");
   auto e = ml::make_dataset(t, {"f2"}, +1);
   check("X", e.X, std::vector<ml::Vec>{{1, 2}, {1, -1}, {1, 4}});
   check("y", e.y, std::vector<int>{-1, -1, +1});
   auto threw{false};
   try {
      ml::make_dataset(t, {"f3"}, +1);
   } catch (std::runtime_error const&) {
      threw = true;
   }
   check("lanza std::runtime_error si falta una columna", threw, true);
   return summary("ej02");
}
