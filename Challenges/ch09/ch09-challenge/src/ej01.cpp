// Exercise 1: read the Pong CSV
// The full statement is in the Challenge document.
#include "../include/ml/ml.hpp"
#include <istream>

namespace ml {

using namespace std;

Table read_csv(std::istream &in) {
  Table t;
  string line;
  getline(in, line);
  if (!line.empty() && line.back() == '\r') { // FIX F1
    line.pop_back();
  }

  if (line.empty()) {
    return t;
  }
  if (!(line[0] == '#')) {
    t.columns = split(line, ';'); // FIX E1
  }

  bool cabecera = t.columns.empty();      // FIX E2
  while (cabecera && getline(in, line)) { // FIX F2
    if (line[0] == '#' or line.empty()) {
      continue;
    }
    if (line.back() == '\r') {
      line.pop_back();
    }
    t.columns = split(line, ';');
    cabecera = false;
  }

  while (getline(in, line)) {
    if (!line.empty() && line.back() == '\r') {
      line.pop_back();
    } // FIX F3
    if (line.empty() or line[0] == '#') {
      continue;
    } // FIX S1
    t.rows.push_back(split(line, ';'));
  }
  return t;
}

int column_index(Table const &t, std::string const &name) {
  for (auto i{0uz}; i < t.columns.size(); i++) {
    if (t.columns[i] == name) {
      return static_cast<int>(i);
    }
  }
  return -1;
}

} // namespace ml
