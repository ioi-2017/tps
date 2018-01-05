#include "testlib.h"
#include <string>
using namespace std;

#define MAX (1024)
int main(int argc, char ** argv){
	registerValidation(argc, argv);
	int m = inf.readInt(1, MAX, "m");
	inf.readSpace();
	int n = inf.readInt(1, MAX, "n");
	inf.readSpace();
	int opt = inf.readInt(1, MAX*MAX, "opt");
	inf.readEoln();
	int free = 0;
	for (int i = 0; i < m; i++) {
		string s = inf.readLine("[.#]{" + std::to_string(n) + "," + std::to_string(n) + "}");
		for (int j = 0; j < n; j++)
			if (s[j] == '.') free++;
	}

	ensuref(opt >= free / 6, "Answer (%d) < number of free cells (%d) / 6", opt, free);
	inf.readEof();
	return 0;
}
