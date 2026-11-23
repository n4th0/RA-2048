// Exercise 9: Pocket
// The full statement is in the Training document.
#include "ml/ml.hpp"

namespace ml {

PocketResult pocket(Dataset const& d, Vec w, int max_updates, Rng& rng) {
   PocketResult best{w, accuracy(w, d), 0};
   // ◉◉YOUR CODE◉◉
   return best;
}

} // namespace ml
