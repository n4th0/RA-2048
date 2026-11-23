// Exercise 10: confusion matrix and weighted error
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"

namespace ml {

Confusion confusion(Vec const &w, Dataset const &d) {
  Confusion c;
  for (std::size_t i = 0; i < d.X.size(); i++) {
    if (d.y[i] * signal(w, d.X[i]) > 0) {
      if (d.y[i] < 0) {
        c.tn++;
      } else {
        c.tp++;
      }
    } else {
      if (d.y[i] < 0) {
        c.fp++;
      } else {
        c.fn++;
      }
    }
  }
  return c;
}

double weighted_error(Confusion const &c, double cost_fn, double cost_fp) {
  double denom = (c.tp + c.fn) * cost_fn;
  if (denom == 0.0) {
    return 0.0;
  }
  return (c.fn * cost_fn + c.fp * cost_fp) / denom;

  // return (c.fn * cost_fn + c.fp * cost_fp) / (c.fn * (c.tp + cost_fn));
  // fix it was left to check the denominator in case it was 0
}

} // namespace ml
