// Exercise 6: standardize
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"
#include <cmath>

namespace ml {

Standardizer fit_standardizer(Dataset const &train) {
  auto const n = train.X.size();
  auto const dims = train.X[0].size();
  Standardizer s{Vec(dims, 0.0), Vec(dims, 1.0)};
  for (size_t j = 1; j < dims; j += 1) {
    auto suma(0.0);
    for (size_t i = 0; i < n; i += 1) {
      suma += train.X[i][j];
    }
    s.mean[j] = suma / n;
  }
  for (size_t j = 1; j < dims; j += 1) {
    auto sq(0.0);
    for (size_t i = 0; i < n; i += 1) {
      sq += (train.X[i][j] - s.mean[j]) * (train.X[i][j] - s.mean[j]);
    }
    auto sd = sqrt(sq / (n - 1));
    s.sd[j] = sd == 0 ? 1 : sd;
  }
  return s;
}

void standardize(Standardizer const &s, Dataset &d) {
  for (auto &x : d.X) {
    for (size_t j = 1; j < x.size(); j += 1) {
      x[j] = (x[j] - s.mean[j]) / s.sd[j];
    }
  }
}

} // namespace ml
