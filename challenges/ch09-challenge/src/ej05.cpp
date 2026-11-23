// Exercise 5: filter rallies
// The full statement is in the Challenge document.
#include "ml/ml.hpp"
#include <stdexcept>

namespace ml {

Table filter_rallies(Table const& t, int result, int skip) {
   auto const m = column_index(t, "match");
   auto const r = column_index(t, "rally");
   auto const f = column_index(t, "frame");
   auto const res = column_index(t, "rally_result");
   auto const side = column_index(t, "side");
   if (m < 0 || r < 0 || f < 0 || res < 0 || side < 0) {
      throw std::runtime_error("faltan columnas del peloteo");
   }

   Table out{t.columns, {}};
   // ◉◉YOUR CODE◉◉
   return out;
}

} // namespace ml
