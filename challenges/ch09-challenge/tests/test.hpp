// Test utilities: make TEST=ejNN
#pragma once
#include <cmath>
#include <format>
#include <print>
#include <sstream>
#include <string>
#include <vector>
#include "ml/ml.hpp"

namespace test {

inline auto g_fail{0};

inline std::string show(double v) { return std::format("{:.6g}", v); }
inline std::string show(int v) { return std::to_string(v); }
inline std::string show(std::size_t v) { return std::to_string(v); }
inline std::string show(bool v) { return v ? "true" : "false"; }
inline std::string show(std::string const& s) { return '"' + s + '"'; }
template <typename T>
std::string show(std::vector<T> const& v) {
   std::string s = "[";
   for (auto i{0uz}; i < v.size(); i += 1) { s += (i ? ", " : "") + show(v[i]); }
   return s + "]";
}

inline bool same(double a, double b) {
   return std::abs(a - b) <= 1e-6 * std::max(1.0, std::abs(b));
}
inline bool same(int a, int b) { return a == b; }
inline bool same(std::size_t a, std::size_t b) { return a == b; }
inline bool same(bool a, bool b) { return a == b; }
inline bool same(std::string const& a, std::string const& b) { return a == b; }
template <typename T>
bool same(std::vector<T> const& a, std::vector<T> const& b) {
   if (a.size() != b.size()) { return false; }
   for (auto i{0uz}; i < a.size(); i += 1) {
      if (!same(a[i], b[i])) { return false; }
   }
   return true;
}

// Compares what was obtained with what was expected and prints OK or Falla
template <typename T, typename U>
void check(std::string const& what, T const& got, U const& expected) {
   T const exp = expected;
   if (same(got, exp)) {
      std::println("  OK     {}", what);
   } else {
      g_fail += 1;
      std::println("  Falla  {}\n         esperado: {}\n         obtenido: {}", what,
                   show(exp), show(got));
   }
}

// Column j (the 1st by default) of each row of X
inline std::vector<double> column(ml::Dataset const& d, std::size_t j = 1) {
   std::vector<double> c;
   for (auto const& x : d.X) { c.push_back(x[j]); }
   return c;
}

// A Dataset with the column x1 = 0, 1, 2... (to follow which rows are left)
inline ml::Dataset numbered(std::vector<int> const& match, std::vector<int> const& y) {
   ml::Dataset d;
   for (auto i{0uz}; i < y.size(); i += 1) {
      d.X.push_back({1.0, static_cast<double>(i)});
      d.y.push_back(y[i]);
      d.match.push_back(match[i]);
   }
   return d;
}

// A Dataset with the given points (each one with x0 = 1 already in place)
inline ml::Dataset points(std::vector<ml::Vec> const& X, std::vector<int> const& y) {
   ml::Dataset d;
   d.X = X;
   d.y = y;
   d.match.assign(y.size(), 1);
   return d;
}

inline ml::Table table(std::string const& csv) {
   std::istringstream in(csv);
   return ml::read_csv(in);
}

inline int summary(char const* ej) {
   auto const verdict = g_fail == 0 ? "todo OK"
                                    : std::format("{} comprobación(es) fallan", g_fail);
   std::println("{}: {}", ej, verdict);
   return g_fail == 0 ? 0 : 1;
}

} // namespace test
