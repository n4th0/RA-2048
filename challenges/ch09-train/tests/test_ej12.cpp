#include <sstream>
#include "test.hpp"
using namespace test;

int main() {
   std::println("P1: pesos sin estandarizar");
   ml::Standardizer s{{0, 3, 10}, {1, 2, 5}};
   auto raw = ml::to_raw_weights({1, 2, -1}, s);
   check("to_raw_weights([1, 2, -1])", raw, ml::Vec{0, 1, -0.2});
   // Check: the same signal with the raw point (5, 20) as with the standardized (1, 2)
   check("señal con el punto sin estandarizar", ml::signal(raw, {1, 5, 20}),
         ml::signal({1, 2, -1}, {1, 1, 2}));

   std::println("P2: fichero de pesos para el Pong");
   std::ostringstream out;
   ml::write_weights(out, "Azules", {0, 1, -0.2}, {3, -2, 0.5});
   check("texto escrito", out.str(), std::string{"#@name Azules\n0 1 -0.2\n3 -2 0.5\n"});
   return summary("ej12");
}
