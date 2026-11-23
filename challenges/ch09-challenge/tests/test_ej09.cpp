#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: 8 puntos no separables, 500 actualizaciones como máximo, "
                "semilla 39: para por la paciencia");
   auto d = points({{1, 0, 1}, {1, 3, 0}, {1, -2, 1}, {1, -1, 0}, {1, 2, -3}, {1, 1, -3},
                    {1, 3, 1}, {1, -1, 3}}, {1, -1, -1, -1, 1, -1, -1, 1});
   ml::Rng r1{39};
   auto p = ml::pocket(d, {0, 0, 0}, 500, r1);
   check("w", p.w, ml::Vec{-4, -1, 5});
   check("accuracy", p.accuracy, 0.73333333333333339);
   check("update", p.update, 54);

   std::println("P2: otros 8 puntos no separables, semilla 3");
   auto e = points({{1, -3, -1}, {1, 1, -2}, {1, -3, -3}, {1, 2, 0}, {1, 3, -2},
                    {1, 3, 3}, {1, 2, 3}, {1, 3, 2}}, {-1, -1, 1, 1, 1, 1, -1, 1});
   ml::Rng r2{3};
   auto q = ml::pocket(e, {0, 0, 0}, 500, r2);
   check("w", q.w, ml::Vec{1, 3, 3});
   check("accuracy", q.accuracy, 0.73333333333333339);
   check("update", q.update, 1);
   return summary("ej09");
}
