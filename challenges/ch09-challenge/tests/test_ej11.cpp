#include <cmath>
#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: cotas, como mucho 1");
   check("hoeffding_bound(0.1, 100, 1)", ml::hoeffding_bound(0.1, 100, 1),
         2 * std::exp(-2.0));
   check("hoeffding_bound(0.1, 25, 1)", ml::hoeffding_bound(0.1, 25, 1), 1.0);
   check("hoeffding_bound(0.1, 250, 100)", ml::hoeffding_bound(0.1, 250, 100), 1.0);
   check("hoeffding_epsilon(1000, 0.05, 1)", ml::hoeffding_epsilon(1000, 0.05, 1),
         std::sqrt(std::log(40.0) / 2000));

   std::println("P2: número máximo de hipótesis");
   check("max_hypotheses(0.1, 500, 0.05)", ml::max_hypotheses(0.1, 500, 0.05),
         std::floor(0.025 * std::exp(10.0)));
   check("max_hypotheses(0.1, 250, 0.05)", ml::max_hypotheses(0.1, 250, 0.05), 3.0);
   check("max_hypotheses(0.05, 400, 0.1)", ml::max_hypotheses(0.05, 400, 0.1), 0.0);
   return summary("ej11");
}
