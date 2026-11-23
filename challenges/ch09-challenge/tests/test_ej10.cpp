#include "test.hpp"
using namespace test;

std::vector<int> as_vec(ml::Confusion const& c) { return {c.tp, c.fp, c.fn, c.tn}; }

int main() {
   std::println("P1: matriz de confusión con w = [0, 0, 1] (una señal 0 en cada clase)");
   // signals: 3, 0 (y = +1) and 0, -2, 1, -1 (y = -1)
   auto d = points({{1, 5, 3}, {1, -1, 0}, {1, 2, 0}, {1, 0, -2}, {1, 1, 1}, {1, -4, -1}},
                   {1, 1, -1, -1, -1, -1});
   check("[tp, fp, fn, tn]", as_vec(ml::confusion({0, 0, 1}, d)),
         std::vector<int>{1, 2, 1, 2});

   std::println("P2: error ponderado relativo al bot que nunca pulsa");
   check("bot que pulsa", ml::weighted_error({25, 60, 15, 900}, 10, 1), 210.0 / 400);
   check("nunca pulsa", ml::weighted_error({0, 0, 40, 960}, 10, 1), 1.0);
   check("otros costes", ml::weighted_error({30, 100, 10, 860}, 4, 2),
         (4 * 10 + 2 * 100) / 160.0);
   return summary("ej10");
}
