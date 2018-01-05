#include "prize.h"
#include <cstdlib>

int recursive_find_best(int n, int m, int s, int e, int xl, int xr) {
  std::vector<int> r, r0;
  if (xl + xr >= m) return -1;
  if (e - s < 2) {
    for (int i = s; i <= e; ++i) {
      r = ask(i);
      if (r[0] + r[1] == 0) return i;
    }
    return -1;
  }
  int midl = (s + e) / 2, midr = (s + e) / 2;
  r0 = ask(midl);
  if (r0[0] + r0[1] == 0) return midl;
  for (r = r0, --midl; r[0] + r[1] < m && midl > s; --midl) {
    r = ask(midl);
    if (r[0] + r[1] == 0) return midl;
  }
  int ans = recursive_find_best(n, m, s, midl, xl, r[1]);
  if (ans >= 0) return ans;
  for (r = r0, ++midr; r[0] + r[1] < m && midr < e; ++midr) {
    r = ask(midr);
    if (r[0] + r[1] == 0) return midr;
  }
  return recursive_find_best(n, m, midr, e, r[0], xr);
}
			
int find_best(int n) {
  int m = 0;
  for (int i = 0; i < 250; ++i) {
    std::vector<int> r = ask(std::rand() % n);
    if (r[0] + r[1] > m) m = r[0] + r[1];
  }
  return recursive_find_best(n, m, 0, n - 1, 0, 0);
}
