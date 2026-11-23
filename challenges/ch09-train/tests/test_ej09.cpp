#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: datos no separables (XOR y dos puntos más), 20 actualizaciones, "
                "semilla 5");
   auto d = points({{1, 0, 0}, {1, 1, 1}, {1, 0, 1}, {1, 1, 0}, {1, 2, 2}, {1, -1, -1}},
                   {-1, -1, 1, 1, 1, -1});
   ml::Rng r1{5};
   auto p = ml::pocket(d, {0, 0, 0}, 20, r1);
   check("w", p.w, ml::Vec{0, 1, 1});
   check("accuracy", p.accuracy, 4.0 / 6.0);
   check("update", p.update, 2);

   std::println("P2: cuatro puntos separables, semilla 7: para al llegar al 100 %");
   auto e = points({{1, 2, 0}, {1, -3, -2}, {1, 3, 1}, {1, -2, 3}}, {1, 1, 1, -1});
   ml::Rng r2{7};
   auto q = ml::pocket(e, {2, 1, 1}, 50, r2);
   check("w", q.w, ml::Vec{5, 3, -4});
   check("accuracy", q.accuracy, 1.0);
   check("update", q.update, 5);
   return summary("ej09");
}
