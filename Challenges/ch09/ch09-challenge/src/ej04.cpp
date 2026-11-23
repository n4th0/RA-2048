// Exercise 4: balance the classes
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"

namespace ml {

std::array<int, 2> class_counts(std::vector<int> const &y) {
  std::array<int, 2> c{0, 0};
  for (auto const v : y) {
    c[v > 0 ? 1 : 0] += 1;
  }
  return c;
}

Dataset undersample(Dataset const &d, Rng &rng) {
  Dataset out;
  auto const c = class_counts(d.y);
  auto const minority = c[1] <= c[0] ? 1 : -1;
  std::vector<std::size_t> major;
  for (auto i{0uz}; i < d.y.size(); i += 1) {
    if (d.y[i] != minority) {
      major.push_back(i);
    }
  }
  shuffle(major, rng);
  std::vector<bool> keep(d.y.size(), false);

  for (auto i{0uz}; i < d.y.size(); i += 1) {
    keep[i] = d.y[i] == minority;
  }

  auto bound = std::min(c[0], c[1]) *
               2; // FIX E1: puse const por error en una variable...

  if (bound > std::max(c[0], c[1])) {
    bound = std::max(c[0], c[1]);
  }

  for (auto k{0}; k < bound; k += 1) {
    keep[major[k]] = true;
  }

  for (auto i{0uz}; i < d.y.size(); i += 1) {
    if (keep[i]) {
      push_row(out, d, i);
    }
  }

  return out;
}

} // namespace ml
