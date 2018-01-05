#include "prize.h"

int find_best(int n) {
	for(int i = 0; i < n; i++) {
		std::vector<int> res = ask(i);
		if(res[0] + res[1] == 0)
			return i;
	}
	return 0;
}
