#include "test.hpp"
using namespace test;

std::vector<std::string> frames(ml::Table const& t) {
   auto const f = ml::column_index(t, "frame");
   std::vector<std::string> v;
   for (auto const& row : t.rows) { v.push_back(row[f]); }
   return v;
}

int main() {
   auto t = table(
      "match;rally;frame;side;rally_result\n"
      "1;1;0;left;1\n1;1;0;right;-1\n1;1;1;left;1\n1;1;1;right;-1\n"
      "1;1;2;left;1\n1;1;2;right;-1\n1;1;3;left;1\n1;1;3;right;-1\n"
      "1;2;4;left;-1\n1;2;4;right;1\n1;2;5;left;-1\n1;2;5;right;1\n"
      "2;1;0;left;1\n2;1;1;left;1\n2;1;2;left;1\n");

   std::println("P1: lado izquierdo, peloteos ganados, sin los 2 primeros frames");
   check("frames", frames(ml::filter_rallies(t, 1, 2)),
         std::vector<std::string>{"2", "3", "2"});

   std::println("P2: lado izquierdo, peloteos perdidos, sin saltar frames (los ganados "
                "por la derecha no cuentan)");
   auto b = ml::filter_rallies(t, -1, 0);
   check("frames", frames(b), std::vector<std::string>{"4", "5"});
   auto const side = ml::column_index(b, "side");
   auto all_left{true};
   for (auto const& row : b.rows) { all_left = all_left && row[side] == "left"; }
   check("todas del lado left", all_left, true);
   return summary("ej05");
}
