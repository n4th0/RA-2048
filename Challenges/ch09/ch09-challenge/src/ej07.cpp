// Exercise 7: signal and accuracy
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"

namespace ml {

double signal(Vec const &w, Vec const &x) {
  auto s{0.0};
  for (auto i(0uz); i < w.size(); i += 1) {
    s += w[i] * x[i];
  }
  return s;
}

double accuracy(Vec const &w, Dataset const &d) {
  auto pos(0);
  auto neg(0);
  auto count_pos(0.0);
  auto count_neg(0.0);
  for (auto n(0uz); n < d.y.size(); n += 1) {
    if (d.y[n] == 1) {
      pos += 1;
      if (d.y[n] * signal(w, d.X[n]) > 0) {
        count_pos += 1;
      }
    } else {
      neg += 1;
      if (d.y[n] * signal(w, d.X[n]) > 0) {
        count_neg += 1;
      }
    }

  } // FIX F1: Olvido de llave de cierre bucle for
  if (pos == 0) {
    return count_neg / neg;
  }
  if (neg == 0) {
    return count_pos / pos;
  }
  auto acc_pos = count_pos / pos;
  auto acc_neg = count_neg / neg;
  return (acc_pos + acc_neg) /
         2; // FIX S1: Error al copiar símbolo "-" en lugar de "+"
}

} // namespace ml
