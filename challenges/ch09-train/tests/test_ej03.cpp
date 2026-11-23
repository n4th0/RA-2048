#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: 4 partidas, la mitad a test, semilla 1");
   auto d = numbered({1, 1, 2, 3, 3, 4, 4, 4}, {1, -1, -1, 1, -1, -1, 1, -1});
   ml::Rng r1{1};
   auto [train, test] = ml::split_by_match(d, 0.5, r1);
   check("filas de entrenamiento (x1)", column(train), std::vector<double>{2, 3, 4});
   check("partidas de entrenamiento", train.match, std::vector<int>{2, 3, 3});
   check("filas de test (x1)", column(test), std::vector<double>{0, 1, 5, 6, 7});
   check("etiquetas de test", test.y, std::vector<int>{1, -1, -1, 1, -1});

   std::println("P2: 5 partidas, un 30 % a test (round(1.5) = 2 partidas), semilla 2");
   auto e = numbered({3, 3, 5, 5, 6, 7, 9, 9}, {1, 1, 1, 1, 1, 1, 1, 1});
   ml::Rng r2{2};
   auto [train2, test2] = ml::split_by_match(e, 0.3, r2);
   check("filas de entrenamiento (x1)", column(train2),
         std::vector<double>{0, 1, 4, 6, 7});
   check("partidas de test", test2.match, std::vector<int>{5, 5, 7});
   return summary("ej03");
}
