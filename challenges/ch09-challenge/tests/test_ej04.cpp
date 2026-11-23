#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: 2 de +1 y 5 de -1: quedan las 2 de +1 y 4 de -1, semilla 3");
   auto d = numbered({1, 1, 1, 1, 1, 1, 1}, {-1, 1, -1, -1, 1, -1, -1});
   auto const counts = ml::class_counts(d.y);
   check("class_counts", std::vector<int>{counts[0], counts[1]}, std::vector<int>{5, 2});
   ml::Rng r1{3};
   auto u = ml::undersample(d, r1);
   check("filas que quedan (x1)", column(u), std::vector<double>{0, 1, 2, 3, 4, 6});
   check("etiquetas", u.y, std::vector<int>{-1, 1, -1, -1, 1, -1});

   std::println("P2: 5 de +1 y 1 de -1 (la minoritaria es -1): quedan 2 de +1, "
                "semilla 4; y una mayoritaria corta");
   auto e = numbered({1, 1, 1, 1, 1, 1}, {1, 1, 1, -1, 1, 1});
   ml::Rng r2{4};
   auto v = ml::undersample(e, r2);
   check("filas que quedan (x1)", column(v), std::vector<double>{0, 2, 3});
   check("etiquetas", v.y, std::vector<int>{1, 1, -1});
   auto f = numbered({1, 1, 1, 1, 1}, {-1, 1, -1, 1, -1});
   ml::Rng r3{5};
   check("3 de -1 y 2 de +1: no hay 4 de -1, quedan todas",
         column(ml::undersample(f, r3)), std::vector<double>{0, 1, 2, 3, 4});
   return summary("ej04");
}
