// Exercise 6: standardize
// The full statement is in the Challenge document.
#include "ml/ml.hpp"
#include <cmath>

namespace ml {

Standardizer fit_standardizer(Dataset const& train) {
   auto const n = train.X.size();
   auto const dims = train.X[0].size();
   Standardizer s{Vec(dims, 0.0), Vec(dims, 1.0)};
   // ◉◉YOUR CODE◉◉
   return s;
}

void standardize(Standardizer const& s, Dataset& d) {
   // ◉◉YOUR CODE◉◉
}

} // namespace ml
