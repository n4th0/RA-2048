#include "test.hpp"
using namespace test;

int main() {
   // Four separable points: 3 of +1 and 1 of -1
   auto d = points({{1, 2, 0}, {1, -3, -2}, {1, 3, 1}, {1, -2, 3}}, {1, 1, 1, -1});

   std::println("P1: PLA desde [2, 1, 1] hasta converger");
   auto r = ml::pla(d, {2, 1, 1}, 100);
   check("w", r.w, ml::Vec{3, 2, -4});
   check("updates", r.updates, 3);
   check("converged", r.converged, true);

   std::println("P2: el mismo PLA con un máximo de 2 actualizaciones, y desde "
                "w = [0, 0, 0]");
   auto s = ml::pla(d, {2, 1, 1}, 2);
   check("w", s.w, ml::Vec{4, 0, -1});
   check("updates", s.updates, 2);
   check("converged", s.converged, false);
   auto z = ml::pla(d, {0, 0, 0}, 100);
   check("w desde [0, 0, 0] (todas las señales 0: todas mal clasificadas)", z.w,
         ml::Vec{3, 1, -2});
   check("updates desde [0, 0, 0]", z.updates, 3);
   return summary("ej08");
}
