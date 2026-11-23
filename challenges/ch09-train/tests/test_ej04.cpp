#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: 2 de +1 y 5 de -1, semilla 3");
   auto d = numbered({1, 1, 1, 1, 1, 1, 1}, {-1, 1, -1, -1, 1, -1, -1});
   auto const counts = ml::class_counts(d.y);
   check("class_counts", std::vector<int>{counts[0], counts[1]}, std::vector<int>{5, 2});
   ml::Rng r1{3};
   auto u = ml::undersample(d, r1);
   check("filas que quedan (x1)", column(u), std::vector<double>{1, 2, 4, 6});
   check("etiquetas", u.y, std::vector<int>{1, -1, 1, -1});

   std::println("P2: 5 de +1 y 1 de -1 (ahora la minoritaria es -1), semilla 4");
   auto e = numbered({1, 1, 1, 1, 1, 1}, {1, 1, 1, -1, 1, 1});
   auto const counts2 = ml::class_counts(e.y);
   check("class_counts", std::vector<int>{counts2[0], counts2[1]},
         std::vector<int>{1, 5});
   ml::Rng r2{4};
   auto v = ml::undersample(e, r2);
   check("filas que quedan (x1)", column(v), std::vector<double>{0, 3});
   check("etiquetas", v.y, std::vector<int>{1, -1});
   return summary("ej04");
}
