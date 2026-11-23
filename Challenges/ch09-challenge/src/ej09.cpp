// Exercise 9: Pocket
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"

namespace ml {

PocketResult pocket(Dataset const& d, Vec w, int max_updates, Rng& rng) {
   PocketResult best{w, accuracy(w, d), 0};
   for(int u=1;(u - best.update) <= 50 && best.accuracy < 1.0 && u <= max_updates; u++){ //Fix (S): donde estaba el (u - best.accuracy) es taba puesto <= 0 // 
      std::vector<std::size_t> wrong;
      for(std::size_t n=0; n<d.X.size(); n++){
         if (d.y[n] * signal(w, d.X[n]) <= 0){
            wrong.push_back(n);
         } 
      }
      if (wrong.empty()){
         best = {w, 1.0, u};
         break;
      }
      std::size_t idx = wrong[rng.below(wrong.size())];
      for(std::size_t i=0; i<w.size(); i++){
         w[i] += d.y[idx] * d.X[idx][i];
      }
      double acc = accuracy(w, d);
      if (acc > best.accuracy){
         best = {w, acc, u};
      }
   }
   return best;
}

}// namespace ml
