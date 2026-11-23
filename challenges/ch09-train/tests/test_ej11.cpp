#include <cmath>
#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: cotas con M = 1 y M = 100, y una tolerancia");
   check("hoeffding_bound(0.1, 100, 1)", ml::hoeffding_bound(0.1, 100, 1),
         2 * std::exp(-2.0));
   check("hoeffding_bound(0.1, 250, 100)", ml::hoeffding_bound(0.1, 250, 100),
         200 * std::exp(-5.0));
   check("hoeffding_epsilon(1000, 0.05, 1)", ml::hoeffding_epsilon(1000, 0.05, 1),
         std::sqrt(std::log(40.0) / 2000));

   std::println("P2: tamaños de muestra con M = 1 y M = 100");
   check("min_samples(0.1, 0.05, 1)", ml::min_samples(0.1, 0.05, 1), 185);
   check("min_samples(0.05, 0.05, 1)", ml::min_samples(0.05, 0.05, 1), 738);
   check("min_samples(0.1, 0.05, 100)", ml::min_samples(0.1, 0.05, 100), 415);
   return summary("ej11");
}
