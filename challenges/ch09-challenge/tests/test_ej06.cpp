#include <cmath>
#include "test.hpp"
using namespace test;

int main() {
   auto d = points({{1, 1, 10}, {1, 3, 10}, {1, 5, 10}}, {1, -1, 1});

   std::println("P1: media y desviación muestral (N - 1); la de x2 es 0: se usa 1");
   auto s = ml::fit_standardizer(d);
   check("mean", s.mean, ml::Vec{0, 3, 10});
   check("sd", s.sd, ml::Vec{1, 2, 1});

   std::println("P2: estandarizar el mismo conjunto y otro (test) con la media y la "
                "desviación de P1");
   ml::standardize(s, d);
   check("X estandarizado", d.X, std::vector<ml::Vec>{{1, -1, 0}, {1, 0, 0}, {1, 1, 0}});
   auto other = points({{1, 7, 12}}, {1});
   ml::standardize(s, other);
   check("X de test", other.X, std::vector<ml::Vec>{{1, 2, 2}});
   return summary("ej06");
}
