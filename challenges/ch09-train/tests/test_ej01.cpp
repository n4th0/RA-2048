#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: CSV sencillo");
   auto t = table("a;b;c\n1;2;3\n4;5;6\n");
   check("columnas", t.columns, std::vector<std::string>{"a", "b", "c"});
   check("número de filas", t.rows.size(), std::size_t{2});
   check("fila 1", t.rows.size() > 1 ? t.rows[1] : std::vector<std::string>{},
         std::vector<std::string>{"4", "5", "6"});
   check("column_index(\"b\")", ml::column_index(t, "b"), 1);
   check("column_index(\"z\")", ml::column_index(t, "z"), -1);

   std::println("P2: finales de línea de Windows, línea vacía y celda vacía");
   auto u = table("x;y\r\n7;\r\n8;9\r\n\n");
   check("columnas", u.columns, std::vector<std::string>{"x", "y"});
   check("número de filas", u.rows.size(), std::size_t{2});
   check("fila 0", u.rows.size() > 0 ? u.rows[0] : std::vector<std::string>{},
         std::vector<std::string>{"7", ""});
   check("fila 1", u.rows.size() > 1 ? u.rows[1] : std::vector<std::string>{},
         std::vector<std::string>{"8", "9"});
   check("column_index(\"y\")", ml::column_index(u, "y"), 1);
   return summary("ej01");
}
