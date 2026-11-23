// train: trains Pong's two perceptrons with your data and your functions.
//
//   ./train [options] DATA.csv [MORE-DATA.csv ...]
//
// For each problem ("do I press up?" and "do I press down?"):
//   filter rallies -> Dataset -> split by match -> balance train
//   -> standardize -> Pocket -> evaluate on test -> unstandardized weights
// and it writes the two AIs to a weights file for Pong.
#include <algorithm>
#include <charconv>
#include <cmath>
#include <cstdlib>
#include <format>
#include <fstream>
#include <print>
#include <stdexcept>
#include <string_view>
#include "ml/ml.hpp"

namespace {

// The 7 features of the original Pong (pong play --obs legacy)
std::vector<std::string> const kFeatures{"jugadorVY", "enemigoYRel", "enemigoVY",
                                         "pelotaXRel", "pelotaYRel", "pelotaVX",
                                         "pelotaVY"};

struct Options {
   std::vector<std::string> files;
   std::string out{"equipo.data"};
   std::string name{"Equipo"};
   bool filter{true};
   int result{1};
   int skip{10};
   double test{0.25};
   std::uint64_t seed{1};
   int updates{2000};
   double cost_fn{10};
   double cost_fp{1};
   double delta{0.05};
};

void usage() {
   std::print(R"(Uso: ./train [opciones] DATOS.csv [MAS-DATOS.csv ...]

  -o FICHERO        fichero de pesos para el Pong                [equipo.data]
  --name NOMBRE     nombre de tu IA (sale en el marcador)        [Equipo]
  --result R        filtro: peloteos con rally_result = R        [1: ganados]
  --skip K          filtro: sin los K primeros frames del peloteo [10]
  --no-filter       sin filtrar
  --test F          fracción de partidas para test               [0.25]
  --seed S          semilla del reparto y del equilibrado        [1]
  --updates U       actualizaciones de Pocket                    [2000]
  --cost-fn C       coste de no pulsar cuando tocaba             [10]
  --cost-fp C       coste de pulsar cuando no tocaba             [1]
  --delta D         Hoeffding: la garantía es 1 - D              [0.05]
)");
}

template <typename T>
T number(std::string_view opt, std::string_view v) {
   T out{};
   auto const [p, ec] = std::from_chars(v.data(), v.data() + v.size(), out);
   if (ec != std::errc{} || p != v.data() + v.size()) {
      throw std::runtime_error(std::format("{}: '{}' no es un número", opt, v));
   }
   return out;
}

Options parse(int argc, char** argv) {
   Options o;
   std::vector<std::string_view> a(argv + 1, argv + argc);
   for (auto i{0uz}; i < a.size(); i += 1) {
      // the value that follows the option
      auto val = [&]() -> std::string_view {
         if (i + 1 >= a.size()) {
            throw std::runtime_error(std::format("{} necesita un valor", a[i]));
         }
         i += 1;
         return a[i];
      };
      auto const opt = a[i];
      if (opt == "-h" || opt == "--help") {
         usage();
         std::exit(0);
      } else if (opt == "-o") {
         o.out = val();
      } else if (opt == "--name") {
         o.name = val();
      } else if (opt == "--result") {
         o.result = number<int>(opt, val());
      } else if (opt == "--skip") {
         o.skip = number<int>(opt, val());
      } else if (opt == "--no-filter") {
         o.filter = false;
      } else if (opt == "--test") {
         o.test = number<double>(opt, val());
      } else if (opt == "--seed") {
         o.seed = number<std::uint64_t>(opt, val());
      } else if (opt == "--updates") {
         o.updates = number<int>(opt, val());
      } else if (opt == "--cost-fn") {
         o.cost_fn = number<double>(opt, val());
      } else if (opt == "--cost-fp") {
         o.cost_fp = number<double>(opt, val());
      } else if (opt == "--delta") {
         o.delta = number<double>(opt, val());
      } else if (opt.starts_with("-")) {
         throw std::runtime_error(std::format("opción desconocida {}", opt));
      } else {
         o.files.emplace_back(opt);
      }
   }
   if (o.files.empty()) {
      usage();
      std::exit(1);
   }
   return o;
}

// Joins several CSV files with the same header. Each file numbers its matches
// from 1: so they do not get mixed, those of file k become k * 100000 + match
ml::Table load_all(std::vector<std::string> const& files) {
   ml::Table all;
   for (auto k{0uz}; k < files.size(); k += 1) {
      std::ifstream in(files[k]);
      if (!in) { throw std::runtime_error("no se puede abrir " + files[k]); }
      auto t = ml::read_csv(in);
      if (k == 0) {
         all.columns = t.columns;
      } else if (t.columns != all.columns) {
         throw std::runtime_error(files[k] + ": la cabecera no coincide");
      }
      auto const m = ml::column_index(t, "match");
      if (m < 0) { throw std::runtime_error(files[k] + ": no tiene la columna match"); }
      for (auto& row : t.rows) {
         row[m] = std::to_string(static_cast<long>(k) * 100000 + std::stol(row[m]));
         all.rows.push_back(std::move(row));
      }
   }
   return all;
}

std::size_t matches_in(ml::Dataset const& d) {
   auto m = d.match;
   std::ranges::sort(m);
   return static_cast<std::size_t>(std::ranges::unique(m).begin() - m.begin());
}

// Trains and evaluates one problem; returns the unstandardized weights
ml::Vec train_one(std::string_view title, ml::Table const& table, int target,
                  Options const& o) {
   std::println("\n=== {} (action = {}) ===", title, target);
   auto data = ml::make_dataset(table, kFeatures, target);
   ml::Rng rng{o.seed};
   auto [train, test] = ml::split_by_match(data, o.test, rng);
   auto const ct = ml::class_counts(train.y);
   auto const cs = ml::class_counts(test.y);
   std::println("Partidas: {} de entrenamiento, {} de test", matches_in(train),
                matches_in(test));
   std::println("Entrenamiento: {} filas ({} de +1, {:.1f} %)", train.y.size(), ct[1],
                100.0 * ct[1] / train.y.size());
   std::println("Test:          {} filas ({} de +1, {:.1f} %)", test.y.size(), cs[1],
                100.0 * cs[1] / test.y.size());
   if (train.y.empty() || test.y.empty() || ct[1] == 0 || cs[1] == 0) {
      throw std::runtime_error("faltan datos: graba más partidas o cambia el filtro");
   }

   auto balanced = ml::undersample(train, rng);
   std::println("Equilibrado:   {} filas", balanced.y.size());
   auto const st = ml::fit_standardizer(balanced);
   ml::standardize(st, balanced);
   auto test_std = test;
   ml::standardize(st, test_std);

   auto const best = ml::pocket(balanced, ml::Vec(kFeatures.size() + 1, 0.0),
                                o.updates, rng);
   std::println("Pocket: accuracy equilibrada {:.3f} en el entrenamiento "
                "(actualización {} de {})", best.accuracy, best.update, o.updates);

   auto const c = ml::confusion(best.w, test_std);
   auto const acc = ml::accuracy(best.w, test_std);
   auto const n = static_cast<int>(test.y.size());
   auto const eps = ml::hoeffding_epsilon(n, o.delta, 1);
   std::println("Test: VP {}  FP {}  FN {}  VN {}", c.tp, c.fp, c.fn, c.tn);
   auto const plain = static_cast<double>(c.tp + c.tn) / n;
   std::println("Test: accuracy equilibrada {:.3f}", acc);
   std::println("Test: accuracy (VP + VN) / N {:.3f} ± {:.3f} (Hoeffding, garantía "
                "{:.0f} %)", plain, eps, 100 * (1 - o.delta));
   ml::Confusion const never{0, 0, cs[1], cs[0]};
   std::println("Test: error ponderado relativo {:.3f}; el bot que nunca pulsa: {:.3f} "
                "(costes FN {}, FP {})", ml::weighted_error(c, o.cost_fn, o.cost_fp),
                ml::weighted_error(never, o.cost_fn, o.cost_fp), o.cost_fn, o.cost_fp);
   std::println("Con ±0.05 y esa garantía, este test vale para elegir entre {} "
                "hipótesis como mucho", ml::max_hypotheses(0.05, n, o.delta));

   auto const raw = ml::to_raw_weights(best.w, st);
   auto const acc_raw = ml::accuracy(raw, test);
   auto const verdict = std::abs(acc_raw - acc) < 1e-9
                           ? " (igual: correcto)"
                           : "  <-- ¡DISTINTA! revisa el Ej. 12";
   std::println("Comprobación: accuracy con los pesos sin estandarizar {:.3f}{}",
                acc_raw, verdict);
   return raw;
}

} // namespace

int main(int argc, char** argv) {
   try {
      auto const o = parse(argc, argv);
      auto table = load_all(o.files);
      std::println("Leídas {} filas de {} fichero(s)", table.rows.size(),
                   o.files.size());
      if (o.filter) {
         table = ml::filter_rallies(table, o.result, o.skip);
         std::println("Filtro: peloteos con rally_result = {}, sin los {} primeros "
                      "frames: {} filas", o.result, o.skip, table.rows.size());
      }
      auto const up = train_one("Arriba", table, -1, o);
      auto const down = train_one("Abajo", table, +1, o);
      std::ofstream out(o.out);
      if (!out) { throw std::runtime_error("no se puede escribir " + o.out); }
      ml::write_weights(out, o.name, up, down);
      std::println("\nPesos escritos en {}. Pruébalos:", o.out);
      std::println("  ./bin/pong match -l perceptron:{} -r expert:2 -n 100 --headless",
                   o.out);
      std::println("  ./bin/pong play -l perceptron:{} -r expert:2", o.out);
   } catch (std::exception const& e) {
      std::println(stderr, "train: {}", e.what());
      return 1;
   }
}
