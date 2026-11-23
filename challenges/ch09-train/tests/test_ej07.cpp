#include "test.hpp"
using namespace test;

int main() {
   // Four separable points: 3 of +1 and 1 of -1
   auto d = points({{1, 2, 0}, {1, -3, -2}, {1, 3, 1}, {1, -2, 3}}, {1, 1, 1, -1});

   std::println("P1: señales y accuracy con w = [2, 1, 1]");
   check("signal(w, P1)", ml::signal({2, 1, 1}, d.X[0]), 4.0);
   check("signal(w, P4)", ml::signal({2, 1, 1}, d.X[3]), 3.0);
   check("accuracy", ml::accuracy({2, 1, 1}, d), 0.5);

   std::println("P2: los pesos finales [3, 2, -4] y una señal 0 (cuenta como fallo)");
   check("accuracy con [3, 2, -4]", ml::accuracy({3, 2, -4}, d), 1.0);
   check("accuracy con [0, 0, 0]", ml::accuracy({0, 0, 0}, d), 0.0);
   return summary("ej07");
}
