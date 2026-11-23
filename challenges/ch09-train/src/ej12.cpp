// Exercise 12: weights for Pong
// The full statement is in the Training document.
#include "ml/ml.hpp"
#include <format>
#include <ostream>

namespace ml {

Vec to_raw_weights(Vec const& w, Standardizer const& s) {
   Vec raw(w.size());
   // ◉◉YOUR CODE◉◉
   return raw;
}

void write_weights(std::ostream& out, std::string const& name, Vec const& up,
                   Vec const& down) {
   // ◉◉YOUR CODE◉◉
}

} // namespace ml
