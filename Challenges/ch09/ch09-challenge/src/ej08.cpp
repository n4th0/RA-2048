// Exercise 8: PLA
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"

namespace ml {

PlaResult pla(Dataset const &d, Vec w, int max_updates) {
  auto updates(0);
  while (true) {
    auto i = d.y.size(); // FIX E1: Inicializar el contador dentro del bucle
    while (i > 0 && d.y[i - 1] * signal(w, d.X[i - 1]) > 0) {
      i -= 1;
    } // FIX E2: Acceso a los índices con -1 en lugar de i
    if (i == 0) {
      return {w, updates, true};
    } // FIX E3: Comparació con -1 en lugar de 0
    if (updates == max_updates) {
      return {w, updates, false};
    }
    for (auto j{0uz}; j < w.size(); j += 1) {
      w[j] += d.y[i - 1] * d.X[i - 1][j];
    }
    updates += 1; // FIX F1: Falta actualizar el contador de updates
  }
}

} // namespace ml
