// The engine's random number generator (the same one Pong uses).
//
// xoshiro256** with a 64-bit seed expanded with splitmix64. It only uses integer
// operations: same seed, same sequence on any machine. That is why we do not use
// <random> or std::shuffle: their results depend on the standard library
// implementation, and the test cases would stop matching between computers.
#pragma once
#include <bit>
#include <cstdint>
#include <utility>
#include <vector>

namespace ml {

struct Rng {
   explicit Rng(std::uint64_t seed = 0) noexcept {
      for (auto& w : s_) { w = splitmix64(seed); }
   }

   std::uint64_t next() noexcept {
      auto const result = std::rotl(s_[1] * 5, 7) * 9;
      auto const t = s_[1] << 17;
      s_[2] ^= s_[0];
      s_[3] ^= s_[1];
      s_[1] ^= s_[2];
      s_[0] ^= s_[3];
      s_[2] ^= t;
      s_[3] = std::rotl(s_[3], 45);
      return result;
   }
   // A uniform real in [0, 1)
   double uniform() noexcept { return static_cast<double>(next() >> 11) * 0x1.0p-53; }
   // A uniform integer in [0, n)
   std::uint64_t below(std::uint64_t n) noexcept {
      __extension__ using u128 = unsigned __int128;
      return static_cast<std::uint64_t>((static_cast<u128>(next()) * n) >> 64);
   }

private:
   static std::uint64_t splitmix64(std::uint64_t& s) noexcept {
      s += 0x9E3779B97F4A7C15ull;
      auto z = s;
      z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ull;
      z = (z ^ (z >> 27)) * 0x94D049BB133111EBull;
      return z ^ (z >> 31);
   }
   std::uint64_t s_[4]{};
};

// Shuffles v (Fisher-Yates): for i = n-1 down to 1, swaps v[i] with v[j], with j
// random in [0, i]
template <typename T>
void shuffle(std::vector<T>& v, Rng& rng) {
   for (auto i{v.size()}; i > 1; i -= 1) {
      std::swap(v[i - 1], v[rng.below(i)]);
   }
}

} // namespace ml
