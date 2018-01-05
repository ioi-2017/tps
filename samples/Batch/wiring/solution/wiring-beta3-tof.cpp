#include "wiring.h"

#include <bits/stdc++.h>
#define MP make_pair
#define PB push_back
#define int long long
#define st first
#define nd second
#define rd third
#define FOR(i, a, b) for(int i =(a); i <=(b); ++i)
#define RE(i, n) FOR(i, 1, n)
#define FORD(i, a, b) for(int i = (a); i >= (b); --i)
#define REP(i, n) for(int i = 0;i <(n); ++i)
#define VAR(v, i) __typeof(i) v=(i)
#define FORE(i, c) for(VAR(i, (c).begin()); i != (c).end(); ++i)
#define ALL(x) (x).begin(), (x).end()
#define SZ(x) ((int)(x).size())
using namespace std;
template<typename TH> void _dbg(const char* sdbg, TH h) { cerr<<sdbg<<"="<<h<<"\n"; }
template<typename TH, typename... TA> void _dbg(const char* sdbg, TH h, TA... t) {
  while(*sdbg != ',')cerr<<*sdbg++; cerr<<"="<<h<<","; _dbg(sdbg+1, t...);
}
#ifdef LOCAL
#define debug(...) _dbg(#__VA_ARGS__, __VA_ARGS__)
#define debugv(x) {{cerr <<#x <<" = "; FORE(itt, (x)) cerr <<*itt <<", "; cerr <<"\n"; }}
#else
#define debug(...) (__VA_ARGS__)
#define debugv(x)
#define cerr if(0)cout
#endif
#define next ____next
#define prev ____prev
#define left ____left
#define hash ____hash
typedef long long ll;
typedef long double LD;
typedef pair<int, int> PII;
typedef pair<ll, ll> PLL;
typedef vector<int> VI;
typedef vector<VI> VVI;
typedef vector<ll> VLL;
typedef vector<pair<int, int> > VPII;
typedef vector<pair<ll, ll> > VPLL;

template<class C> void mini(C&a4, C b4){a4=min(a4, b4); }
template<class C> void maxi(C&a4, C b4){a4=max(a4, b4); }
template<class T1, class T2>
ostream& operator<< (ostream &out, pair<T1, T2> pair) { return out << "(" << pair.first << ", " << pair.second << ")";}
template<class A, class B, class C> struct Triple { A first; B second; C third;
  bool operator<(const Triple& t) const { if (st != t.st) return st < t.st; if (nd != t.nd) return nd < t.nd; return rd < t.rd; } };
template<class T> void ResizeVec(T&, vector<int>) {}
template<class T> void ResizeVec(vector<T>& vec, vector<int> sz) {
  vec.resize(sz[0]); sz.erase(sz.begin()); if (sz.empty()) { return; }
  for (T& v : vec) { ResizeVec(v, sz); }
}
typedef Triple<int, int, int> TIII;
template<class A, class B, class C>
ostream& operator<< (ostream &out, Triple<A, B, C> t) { return out << "(" << t.st << ", " << t.nd << ", " << t.rd << ")"; }
template<class T> ostream& operator<<(ostream& out, vector<T> vec) { out<<"("; for (auto& v: vec) out<<v<<", "; return out<<")"; }


#undef int
long long min_total_length(std::vector<int> rrr, std::vector<int> bbb) {
#define int long long
  int R = SZ(rrr);
  int B = SZ(bbb);
  int socks_cnt = R + B;
  VPII socks{{0, 0}};
  for (auto p : rrr) {
    socks.PB({p, 0});
  }
  for (auto p : bbb) {
    socks.PB({p, 1});
  }
  sort(ALL(socks));
  VI sum_pref(socks_cnt + 5);
  RE (i, socks_cnt) {
    sum_pref[i] = sum_pref[i - 1] + socks[i].st;
  }
  VI go_left(socks_cnt + 5), go_right(socks_cnt + 5);
  go_left[1] = 1;
  FOR (i, 2, socks_cnt) {
    if (socks[i].nd == socks[i - 1].nd) {
      go_left[i] = go_left[i - 1];
    } else {
      go_left[i] = i;
    }
  }
  go_right[socks_cnt] = socks_cnt;
  FORD (i, socks_cnt - 1, 1) {
    if (socks[i].nd == socks[i + 1].nd) {
      go_right[i] = go_right[i + 1];
    } else {
      go_right[i] = i;
    }
  }
  debug(go_left, go_right);
  auto SumInv = [&](int b, int e) {
    assert(b <= e + 1);
    return sum_pref[e] - sum_pref[b - 1];
  };
  auto IsFine = [&](int bb, int ee) {
    if (bb <= 0 || ee > socks_cnt || bb > socks_cnt) { return false; }
    int be = go_right[bb];
    int eb = go_left[ee];
    return be + 1 == eb;
  };
  auto InvAns = [&](int bb, int ee) {
    int be = go_right[bb];
    int eb = go_left[ee];
    assert(be + 1 == eb);
    int n = be - bb + 1, m = ee - eb + 1;
    if (m >= n) {
      return SumInv(eb, ee) - SumInv(bb, be) - (m - n) * socks[be].st;
    }
    return SumInv(eb, ee) - SumInv(bb, be) + (n - m) * socks[eb].st;
  };
  // return InvAns(1, socks_cnt);


  VI dp(socks_cnt + 5, (int)1e18);
  dp[0] = 0;
  RE (i, socks_cnt) {
    int zium = go_left[i];
    if (zium == 1) { continue; }
    zium--;
    int beg = go_left[zium];
    VI to_check;
    FORD (t, zium, zium - 5) {
      to_check.PB(t);
    }
    FOR (t, beg, beg + 5) {
      to_check.PB(t);
    }
    int kl = beg, kp = zium, m = beg;
    while (kl <= kp) {
      int aktc = (kl + kp) / 2;
      if (2 * socks[aktc].st <= socks[beg].st + socks[zium].st) {
        m = aktc;
        kl = aktc + 1;
      } else {
        kp = aktc - 1;
      }
    }
    //int m = (beg + zium) / 2;
    FOR (t, m - 10, m + 10) {
      to_check.PB(t);
    }
    m = (beg + zium) / 2;
    FOR (t, m - 10, m + 10) {
      to_check.PB(t);
    }
    for (auto t : to_check) {
      if (IsFine(t, i)) {
        mini(dp[i], min(dp[t], dp[t - 1]) + InvAns(t, i));
      }
    }

//     while (IsFine(zium, i)) {
//       mini(dp[i], min(dp[zium], dp[zium - 1]) + InvAns(zium, i));
//       zium--;
//     }
  }
  return dp[socks_cnt];
}
