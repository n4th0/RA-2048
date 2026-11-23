// Exercise 3: split training and test by match
// The full statement is in the Challenge document.
#include "ml/ml.hpp"
#include <algorithm>
#include <cmath>
#include <set>

namespace ml {

std::pair<Dataset, Dataset> split_by_match(Dataset const& d, double test_fraction,
                                           Rng& rng) {
   Dataset train;
   Dataset test;
   // ◉◉YOUR CODE◉◉
   return {train, test};
}

} // namespace ml
