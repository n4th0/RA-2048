// Exercise 12: weights for Pong
// The full statement is in the Challenge document.
// #include "ml/ml.hpp"
#include "../include/ml/ml.hpp"
#include <cstddef>
#include <format>
#include <ostream>

namespace ml {

Vec to_raw_weights(Vec const &w, Standardizer const &s) {
  Vec raw(w.size());
  raw[0] = w[0];
  for (std::size_t i = 1; i < w.size(); i++) {
    raw[i] = w[i] / s.sd[i];
    raw[0] -= w[i] * s.mean[i] / s.sd[i];
  }
  return raw;
}

void write_weights(std::ostream &out, std::string const &name, Vec const &up,
                   Vec const &down) {
  out << "#@name " << name << '\n';
  out << "# arriba" << '\n';
  for (std::size_t i = 0; i < up.size(); i++) {
    out << (i ? " " : "") << std::format("{:.8g}", up[i]);
  }
  out << '\n';
  out << "# abajo" << '\n';
  for (std::size_t i = 0; i < down.size(); i++) {
    out << (i ? " " : "") << std::format("{:.8g}", down[i]);
  }
  out << '\n';

  // ◉◉YOUR CODE◉◉
}

} // namespace ml
