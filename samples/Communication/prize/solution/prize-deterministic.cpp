#include "prize.h"

int m = 0;
std::vector<std::vector<int>> saved_result;
#define ASK(r, i, ret) {						\
    r = (saved_result[i].size() > 0)? saved_result[i] : ask(i);		\
    saved_result[i] = r;						\
    if (r[0] + r[1] == 0) return i;					\
    if (r[0] + r[1] > m) { m = r[0] + r[1]; if (ret) return -2; }	\
  }

int recursive_find_best(int n, int s, int e, int xl, int xr) {
  std::vector<int> r, r0;
  if (xl + xr >= m) return -1;
  if (s >= e) {
    ASK(r, s, true);
    return -1;
  }
  int midl = (s + e) / 2, midr = (s + e) / 2;
  ASK(r0, midl, true);
  for (r = r0, --midl; r[0] + r[1] < m && midl > s; --midl) ASK(r, midl, true);
  int ans = recursive_find_best(n, s, midl, xl, r[1]);
  if (ans >= 0 || ans == -2) return ans;
  for (r = r0, ++midr; r[0] + r[1] < m && midr < e; ++midr) ASK(r, midr, true);
  return recursive_find_best(n, midr, e, r[0], xr);
}
		
int find_best(int n) {
  saved_result.resize(n);
  for (int i = 0; i < n; ++i) {
    std::vector<int> r;
    ASK(r, i, false);
    int res = recursive_find_best(n, 0, n - 1, 0, 0);
    if (res >= 0) return res;
  }
  return -1;
}
