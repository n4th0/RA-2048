#include <stdexcept>
#include "test.hpp"
using namespace test;

int main() {
   auto t = table("match;action;f1;f2;agent\n1;-1;0.5;2;Ana\n1;0;1.5;-1;Ana\n"
                  "2;1;-3;4;Ana\n");

   std::println("P1: entradas f1 y f2, problema \"arriba\" (target = -1)");
   auto d = ml::make_dataset(t, {"f1", "f2"}, -1);
   check("X", d.X, std::vector<ml::Vec>{{1, 0.5, 2}, {1, 1.5, -1}, {1, -3, 4}});
   check("y", d.y, std::vector<int>{+1, -1, -1});
   check("match", d.match, std::vector<int>{1, 1, 2});

   std::println("P2: solo f2, problema \"abajo\" (target = +1), y una columna que no "
                "existe");
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
