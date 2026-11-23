// Machine Learning engine for Challenge 9: a perceptron for Pong.
//
// Everything is in the namespace ml. Each function says in which exercise you
// write it; the ones marked "given" are already done in src/given.cpp.
#pragma once
#include <array>
#include <cstdint>
#include <iosfwd>
#include <string>
#include <utility>
#include <vector>
#include "ml/rng.hpp"

namespace ml {

using Vec = std::vector<double>;

//------------------------------------------------------------------------
// Block A. Data
//------------------------------------------------------------------------

// A table read from a CSV: the header names and the cells, as text
struct Table {
   std::vector<std::string>              columns;
   std::vector<std::vector<std::string>> rows;
};

// A dataset ready to learn from: row n is (X[n], y[n])
struct Dataset {
   std::vector<Vec> X;       // inputs, each one with x0 = 1 first
   std::vector<int> y;       // labels: +1 or -1
   std::vector<int> match;   // match each row comes from
};

// (given) Splits a line into cells by the separator
std::vector<std::string> split(std::string const& line, char sep);
// (given) Appends row i of "from" to "to"
void push_row(Dataset& to, Dataset const& from, std::size_t i);

// Exercise 1: reads a CSV with a header and ';' as separator (it skips the empty
// lines and the comments that start with '#')
Table read_csv(std::istream& in);
// Exercise 1: position of the column "name" in the header, or -1 if it is not there
int column_index(Table const& t, std::string const& name);

// Exercise 2: builds the Dataset with the columns "features" as inputs.
// The label is +1 in the rows whose action ("action") is "target", and -1 in the rest.
// It skips the rows with any empty input
Dataset make_dataset(Table const& t, std::vector<std::string> const& features,
                     int target);

// Exercise 3: splits by whole matches: a fraction "test_fraction" of the matches
// (the last ones after shuffling) goes to test (second) and the rest to training (first)
std::pair<Dataset, Dataset> split_by_match(Dataset const& d, double test_fraction,
                                           Rng& rng);

//------------------------------------------------------------------------
// Block B. Preparation
//------------------------------------------------------------------------

// Exercise 4: how many labels there are of each class: {number of -1, number of +1}
std::array<int, 2> class_counts(std::vector<int> const& y);
// Exercise 4: keeps twice as many majority rows as minority rows, at random
Dataset undersample(Dataset const& d, Rng& rng);

// Exercise 5: keeps the rows of the rallies whose result ("rally_result") is
// "result", without the first "skip" frames of each rally, only on the "left" side
Table filter_rallies(Table const& t, int result, int skip);

// Mean and standard deviation of each input (input 0, x0 = 1, is left as it is)
struct Standardizer {
   Vec mean;
   Vec sd;
};
// Exercise 6: computes the mean and the sample standard deviation (N - 1) of each input
Standardizer fit_standardizer(Dataset const& train);
// Exercise 6: standardizes the inputs: (x - mean) / sd
void standardize(Standardizer const& s, Dataset& d);

//------------------------------------------------------------------------
// Block C. Perceptron
//------------------------------------------------------------------------

// Exercise 7: the perceptron signal: s = w · x
double signal(Vec const& w, Vec const& x);
// Exercise 7: balanced accuracy: mean of the accuracy on the +1 rows and on the -1 rows
double accuracy(Vec const& w, Dataset const& d);

struct PlaResult {
   Vec  w;
   int  updates{};      // updates done
   bool converged{};    // true if every row ends up well classified
};
// Exercise 8: PLA correcting the LAST misclassified row, with at most max_updates updates
PlaResult pla(Dataset const& d, Vec w, int max_updates);

struct PocketResult {
   Vec    w;            // the best weights found
   double accuracy{};   // their accuracy on d
   int    update{};     // update where they were found (0: the initial ones)
};
// Exercise 9: PLA correcting a random misclassified row and keeping the best
// weights, by accuracy, in the "pocket"; it stops after 50 updates without improving
PocketResult pocket(Dataset const& d, Vec w, int max_updates, Rng& rng);

//------------------------------------------------------------------------
// Block D. Evaluation and deployment
//------------------------------------------------------------------------

struct Confusion {
   int tp{}, fp{}, fn{}, tn{};   // true and false positives and negatives
};
// Exercise 10: confusion matrix of w on d
Confusion confusion(Vec const& w, Dataset const& d);
// Exercise 10: cost with those costs, relative to that of the bot that never presses
double weighted_error(Confusion const& c, double cost_fn, double cost_fp);

// Exercise 11: Hoeffding bound for M hypotheses: 2 M e^(-2 eps^2 N), at most 1
double hoeffding_bound(double eps, int n, double m);
// Exercise 11: tolerance eps that guarantees the bound delta with N data and M hypotheses
double hoeffding_epsilon(int n, double delta, double m);
// Exercise 11: maximum M for the tolerance eps, N data and the bound delta
double max_hypotheses(double eps, int n, double delta);

// Exercise 12: weights for unstandardized data, equivalent to w on standardized data
Vec to_raw_weights(Vec const& w, Standardizer const& s);
// Exercise 12: writes an AI in Pong's weights format, with a comment before each line
void write_weights(std::ostream& out, std::string const& name, Vec const& up,
                   Vec const& down);

} // namespace ml
