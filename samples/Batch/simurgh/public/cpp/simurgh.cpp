#include "simurgh.h"

std::vector<int> find_roads(int n, std::vector<int> u, std::vector<int> v) {
	std::vector<int> r(n - 1);
	for(int i = 0; i < n - 1; i++)
		r[i] = i;
	int common = count_common_roads(r);
	if(common == n - 1)
		return r;
	r[0] = n - 1;
	return r;
}
