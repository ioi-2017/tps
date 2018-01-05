#include "simurgh.h"

#include <cstdio>
#include <cassert>
#include <vector>
#include <cstdlib>
#include <string>

using namespace std;

static const int CIPHER_SIZE = 64;
static const int CIPHER_KEY[CIPHER_SIZE] = {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0};

template<typename V> 
static int xored(const V& c, int i) {
	return (int)c[i] ^ (CIPHER_KEY[i % CIPHER_SIZE] & 1);
}

static int MAXQ = 30000;

static int n, m, q = 0;
static vector<int> u, v;
static vector<bool> goal;
static vector<int> parent;

static int find(int node) {
	return (parent[node] == node ? node : parent[node] = find(parent[node]));
}

static bool merge(int v1, int v2) {
	v1 = find(v1);
	v2 = find(v2);
	if (v1 == v2)
		return false;
	parent[v1] = v2;
	return true;
}

static void wrong_answer() {
	printf("lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs\n");
	printf("WA\n");
	printf("NO\n");
	exit(0);
}

static bool is_valid(const vector<int>& r) {
	if(int(r.size()) != n - 1)
		return false;

	for(int i = 0; i < n - 1; i++)
		if(r[i] < 0 || r[i] >= m)
			return false;

	parent.resize(n);
	for (int i = 0; i < n; i++) {
		parent[i] = i;
	}
	for (int i = 0; i < n - 1; i++) {
		if (!merge(u[r[i]], v[r[i]])) {
			return false;
		}
	}
	return true;
}

static int _count_common_roads_internal(const vector<int>& r) {
	if (!is_valid(r))
		wrong_answer();

	int common = 0;
	for(int i = 0; i < n - 1; i++) {
		bool is_common = goal[r[i]];
		is_common = xored(goal, r[i]);
		if (is_common)
			common++;
	}

	return common;	
}

int count_common_roads(const vector<int>& r) {
	q++;
	if(q > MAXQ)
		wrong_answer();

	return _count_common_roads_internal(r);
}

int main() {
	{
		char secret[1000];
		assert(1 == scanf("%s", secret));
		if ((string)"wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd" != string(secret)) {
			printf("lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs\n");
			printf("SV\n");
			return 0;
		}
	}
	assert(2 == scanf("%d %d", &n, &m));
	assert(1 == scanf("%d", &MAXQ));

	u.resize(m);
	v.resize(m);

	for(int i = 0; i < m; i++)
		assert(2 == scanf("%d %d", &u[i], &v[i]));

	goal.resize(m, false);

	for(int i = 0; i < n - 1; i++) {
		int id;
		assert(1 == scanf("%d", &id));
		goal[id] = true;
	}

	for (int i = 0; i < m; i++) {
		goal[i] = xored(goal, i);
	}

	vector<int> result = find_roads(n, u, v);

	if(_count_common_roads_internal(result) != n - 1)
		wrong_answer();

	printf("lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs\n");
	printf("OK\n");
	for(int i = 0; i < (int)result.size(); i++){
		if(i)
			printf(" ");
		printf("%d", result[i]);
	}
	printf("\n");

	return 0;
}

