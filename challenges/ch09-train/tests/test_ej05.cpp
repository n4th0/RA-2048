#include "test.hpp"
using namespace test;

// The frames left (column "frame") after the filter
std::vector<std::string> frames(ml::Table const& t) {
   auto const f = ml::column_index(t, "frame");
   std::vector<std::string> v;
   for (auto const& row : t.rows) { v.push_back(row[f]); }
   return v;
}

int main() {
   auto t = table(
      "match;rally;frame;side;rally_result\n"
      "1;1;0;left;1\n1;1;1;left;1\n1;1;2;left;1\n1;1;3;left;1\n1;1;4;left;1\n"
      "1;2;5;left;-1\n1;2;6;left;-1\n1;2;7;left;-1\n"
      "2;1;0;left;1\n2;1;1;left;1\n2;1;2;left;1\n2;1;3;left;1\n"
      "2;2;10;left;1\n2;2;10;right;1\n2;2;11;left;1\n2;2;11;right;1\n"
      "2;2;12;left;1\n2;2;12;right;1\n");

   std::println("P1: peloteos ganados (1), sin los 2 primeros frames");
   auto a = ml::filter_rallies(t, 1, 2);
   check("columnas", a.columns, t.columns);
   check("frames", frames(a),
         std::vector<std::string>{"2", "3", "4", "2", "3", "12", "12"});

   std::println("P2: peloteos perdidos (-1) sin saltar frames, y ganados saltando 1 con "
                "los dos lados grabados");
   check("perdidos, skip 0", frames(ml::filter_rallies(t, -1, 0)),
         std::vector<std::string>{"5", "6", "7"});
   auto b = ml::filter_rallies(t, 1, 1);
   check("ganados, skip 1", frames(b),
         std::vector<std::string>{"1", "2", "3", "4", "1", "2", "3", "11", "11", "12",
                                  "12"});
   return summary("ej05");
}
