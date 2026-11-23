#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: comentarios antes de la cabecera y entre las filas");
   auto t = table("# grabado en clase\n#campo estrecho\na;b;c\n1;2;3\n"
                  "# otra partida\n4;5;6\n");
   check("columnas", t.columns, std::vector<std::string>{"a", "b", "c"});
   check("número de filas", t.rows.size(), std::size_t{2});
   check("fila 1", t.rows.size() > 1 ? t.rows[1] : std::vector<std::string>{},
         std::vector<std::string>{"4", "5", "6"});
   check("column_index(\"c\")", ml::column_index(t, "c"), 2);

   std::println("P2: finales de línea de Windows, comentario, línea vacía y celda vacía");
   auto u = table("x;y\r\n#nota\r\n7;\r\n\r\n8;9\r\n\n");
   check("columnas", u.columns, std::vector<std::string>{"x", "y"});
   check("filas", u.rows, std::vector<std::vector<std::string>>{{"7", ""}, {"8", "9"}});
   check("column_index(\"z\")", ml::column_index(u, "z"), -1);
   return summary("ej01");
}
