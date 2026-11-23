#include "test.hpp"
using namespace test;

int main() {
   // Four separable points: 3 of +1 and 1 of -1
   auto d = points({{1, 2, 0}, {1, -3, -2}, {1, 3, 1}, {1, -2, 3}}, {1, 1, 1, -1});

   std::println("P1: señal y accuracy equilibrada con w = [2, 1, 1]");
   check("signal(w, P2)", ml::signal({2, 1, 1}, d.X[1]), -3.0);
   // +1: 2 of 3 right; -1: 0 of 1 right
   check("accuracy", ml::accuracy({2, 1, 1}, d), (2.0 / 3 + 0.0) / 2);
   check("accuracy con [3, 2, -4]", ml::accuracy({3, 2, -4}, d), 1.0);

   std::println("P2: w = [-1, 0, 0] (todo -1) y un conjunto con una sola clase");
   check("accuracy con [-1, 0, 0]", ml::accuracy({-1, 0, 0}, d), 0.5);
   auto only = points({{1, 1, 0}, {1, -1, 0}}, {1, 1});
   check("solo clase +1", ml::accuracy({0, 1, 0}, only), 0.5);
   return summary("ej07");
}
