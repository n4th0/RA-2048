// Exercise 2: from the CSV to a Dataset
// The full statement is in the Challenge document.
// #include "ml/ml.hpp"

#include "../include/ml/ml.hpp"
#include <stdexcept>

namespace ml {

using namespace std;

Dataset make_dataset(Table const &t, std::vector<std::string> const &features,
                     int target) {
  auto col = [&t](std::string const &name) {
    auto const c = column_index(t, name);
    if (c < 0) {
      throw std::runtime_error("falta la columna " + name);
    }
    return c;
  };

  std::vector<int> fcols;
  for (auto const &f : features) {
    fcols.push_back(col(f));
  }

  auto const action = col("action");
  auto const match = col("match");

  Dataset d;
  for (auto const &row : t.rows) {
    try { // FIX F1
      Vec x{1.0};
      for (auto const c : fcols) {
        x.push_back(stod(row.at(c)));
      }
      int const y = stoi(row.at(action)) == target ? +1 : -1; // FIX E1
      int const m = stoi(row.at(match));
      d.X.push_back(x);
      d.y.push_back(y);
      d.match.push_back(m);
    } catch (std::exception const &) {
      continue;
    }
  }

  return d;
}

} // namespace ml
