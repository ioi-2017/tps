#include "wiring.h"
#include <algorithm>
#include <iostream>

using namespace std;

const int maxbit = 6;

long long dp[1 << maxbit], odp[1 << maxbit];
long long inf = 1e18;

vector<int> used, unused;

int new_mask(int mask) {
	int nmask = mask << 1;
	if(nmask >> maxbit & 1)
		nmask ^= 1 << maxbit;
	return nmask;
}

long long min_total_length(std::vector<int> r, std::vector<int> b) {
	int n = r.size(), m = b.size();
	if(r[n-1] < b[0]) {	
		long long ans = (1LL) * max(n, m) * (b[0] - r[n-1]);
		for(int i = 0; i < n; i ++)
			ans += r[n-1] - r[i];
		for(int i = 0; i < m; i ++)
			ans += b[i] - b[0];
		return ans;
	}
	vector< pair<int, bool> > p;
	for(int i = 0; i < n; i ++)
		p.push_back(make_pair(r[i], 0));
	for(int i = 0; i < m; i ++)
		p.push_back(make_pair(b[i], 1));
	sort(p.begin(), p.end());
       
	for(int i = 0; i < (1 << maxbit); i ++)
		odp[i] = inf;
	odp[0] = 0;

	for(int i = 1; i < n+m; i ++) {
		for(int j = 0; j < (1 << maxbit); j ++)
			dp[j] = inf;

		for(int mask = 0; mask < (1 << maxbit); mask ++) {		
			used.clear();
			unused.clear();
			for(int j = 1; j <= maxbit; j ++)
				if(i-j >= 0 && p[i-j].second != p[i].second) {
					if(mask >> (j-1) & 1)
						used.push_back(j-1);
					else
						unused.push_back(j-1);
				}
			

			///not used
			int nmask = new_mask(mask);
			if(i < maxbit || mask >> (maxbit-1) & 1)
				dp[nmask] = min(dp[nmask], odp[mask]);

                        ///used
			//match to used
			if(used.size() && (i < maxbit || mask >> (maxbit-1) & 1)) {
				nmask = new_mask(mask) + 1;
				dp[nmask] = min(dp[nmask], odp[mask] + p[i].first - p[i-used[0]-1].first);
			}

			//match to unused
			if(unused.size()) {
				reverse(unused.begin(), unused.end());
				int smask = mask;
				long long tmp = odp[mask];
				for(int j = 0; j < unused.size(); j ++) {
					smask |= (1 << unused[j]);
					if(i < maxbit || smask >> (maxbit-1) & 1) {
						nmask = new_mask(smask) + 1;
						tmp += p[i].first - p[i-unused[j]-1].first;
						dp[nmask] = min(dp[nmask], tmp);
					}
				}
			}
		}
		for(int j = 0; j < (1 << maxbit); j ++)
			    odp[j] = dp[j];

	}


	int mask = (1 << maxbit) - 1;
	if(n+m < maxbit) {
		mask = 0;
		for(int i = 0; i < n+m; i ++)
			mask |= (1 << i);
	}


	return odp[mask];
}
