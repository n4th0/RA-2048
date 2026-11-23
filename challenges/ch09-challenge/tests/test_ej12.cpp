#include <sstream>
#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: pesos sin estandarizar");
   ml::Standardizer s{{0, 4, -2}, {1, 2, 0.5}};
   auto raw = ml::to_raw_weights({1, 3, 1}, s);
   check("to_raw_weights([1, 3, 1])", raw, ml::Vec{-1, 1.5, 2});
   check("señal con el punto sin estandarizar", ml::signal(raw, {1, 6, -1}),
         ml::signal({1, 3, 1}, {1, 1, 2}));

   std::println("P2: fichero de pesos con comentarios");
   std::ostringstream out;
   ml::write_weights(out, "Rojos", {0, 1.123456789, -0.2}, {3, -2, 0.5});
   check("texto escrito", out.str(),
         std::string{"#@name Rojos\n# arriba\n0 1.1234568 -0.2\n# abajo\n3 -2 0.5\n"});
   return summary("ej12");
}
