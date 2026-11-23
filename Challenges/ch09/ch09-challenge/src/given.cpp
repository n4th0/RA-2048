// Routines that are already solved
#include "ml/ml.hpp"
#include <sstream>

namespace ml {

std::vector<std::string> split(std::string const& line, char sep) {
   std::vector<std::string> cells;
   std::istringstream in(line);
   for (std::string cell; std::getline(in, cell, sep);) { cells.push_back(cell); }
   if (!line.empty() && line.back() == sep) { cells.emplace_back(); }   // empty last cell
   return cells;
}

void push_row(Dataset& to, Dataset const& from, std::size_t i) {
   to.X.push_back(from.X[i]);
   to.y.push_back(from.y[i]);
   to.match.push_back(from.match[i]);
}

} // namespace ml
