// Exercise 11: Hoeffding
// The full statement is in the Challenge document.
// #include "ml/ml.hpp"

#include "../include/ml/ml.hpp"
#include <algorithm>
#include <cmath>

namespace ml {

double hoeffding_bound(double eps, int n, double m) {
  double sol = 2.0 * m * std::exp(-2.0 * eps * eps * n);
  if (sol > 1)
    return 1;
  else
    return sol;
  // ◉◉YOUR CODE◉◉
}

double hoeffding_epsilon(int n, double delta, double m) {
  return std::sqrt(std::log((2.0 * m) / delta) /
                   (2.0 * n)); // Fix 1 syntax error ( wrong placed
}

double max_hypotheses(double eps, int n, double delta) {
  return std::floor(
      (delta / 2.0) *
      std::exp(2.0 * eps * eps *
               n)); // Fix error of calculation (wrong formula applied)

  // return static_cast<double>(
  //     std::exp((std::floor(delta / 2.0)) + 2.0 * eps * eps * n));
  // // ◉◉YOUR CODE◉◉
  // return 0;
}

} // namespace ml
