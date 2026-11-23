// Exercise 3: split training and test by match
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"
#include <algorithm>
#include <cmath>
#include <set>

namespace ml {

std::pair<Dataset, Dataset> split_by_match(Dataset const &d,
                                           double test_fraction, Rng &rng) {
  Dataset train;
  Dataset test;
  std::set<int> const distinct(d.match.begin(), d.match.end());
  std::vector<int> ids(distinct.begin(), distinct.end());
  shuffle(ids, rng);

  auto const k =
      static_cast<std::size_t>(std::round(test_fraction * ids.size()));
  std::set<int> const test_ids(ids.end() - k, ids.end());

  for (auto i{0uz}; i < d.y.size(); i += 1) {
    push_row(test_ids.contains(d.match[i]) ? test : train, d, i);
  }
  return {train, test};
}

} // namespace ml
