#include "test.hpp"
using namespace test;

std::vector<int> as_vec(ml::Confusion const& c) { return {c.tp, c.fp, c.fn, c.tn}; }

int main() {
   std::println("P1: matriz de confusión con w = [0, 1, 0] (una señal 0 en cada clase)");
   // signals: 2, 0, -1 (y = +1) and 0, -3, 1 (y = -1)
   auto d = points({{1, 2, 5}, {1, 0, 1}, {1, -1, 0}, {1, 0, -2}, {1, -3, 3}, {1, 1, 1}},
                   {1, 1, 1, -1, -1, -1});
   check("[tp, fp, fn, tn]", as_vec(ml::confusion({0, 1, 0}, d)),
         std::vector<int>{1, 2, 2, 1});

   std::println("P2: error ponderado de un bot que pulsa y del que nunca pulsa");
   check("bot que pulsa", ml::weighted_error({25, 60, 15, 900}, 10, 1), 0.21);
   check("nunca pulsa", ml::weighted_error({0, 0, 40, 960}, 10, 1), 0.40);
   return summary("ej10");
}
