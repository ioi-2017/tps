#include "coins.h"
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <iostream>
#include <cassert>
using namespace std;

static const string input_secret = "8ad886d6-2d9e-4cab-aaed-47175facae96";
static const string pipe_secret = "3f900aa0-f7c9-4935-ac07-3f34523a67ab";
static const string output_secret = "aa118b2a-086a-420f-811f-e3648ef86a25";

static const int board_width = 8;
static const int board_height = 8;
static const int board_size = board_width * board_height;

static void shuffle(vector<int> &v){
	srand(850928);
	random_shuffle(v.begin(), v.end());
}

static FILE* pipe1;

static void error1(string msg = "WA", string reason= "") {
	fprintf(pipe1, "%s\n", pipe_secret.c_str());
	fprintf(pipe1, "%s\n", msg.c_str());
	fprintf(pipe1, "%s\n", reason.c_str());
	fclose(pipe1);
	exit(0);
}

static void pass1(char* pipe_path) {
	fclose(stdout);
	
	pipe1 = fopen(pipe_path, "w");

	char secret[1000];
	assert(1 == scanf("%s", secret));
	if (string(secret) != input_secret) {
		error1("SV");
	}

	int tests, k;
	assert(2 == scanf("%d %d", &tests, &k));

	vector<int> cs(tests);
	vector<vector<int> > bs(tests);

	for (int t = 0; t < tests; t++) {
		assert(1 == scanf("%d", &cs[t]));
		bs[t].resize(board_size);
		for (int i = 0; i < board_height; i++) {
			char row[board_width+2];
			assert(1 == scanf("%s", row));
			for(int j = 0; j < board_width; j++) {
				bs[t][i * board_width + j] = int(row[j] - '0');
			}
		}
	}

	fclose(stdin);

	for (int t = 0; t < tests; t++) {
		vector<int> board_copy = bs[t];
		vector<int> flips = coin_flips(board_copy, cs[t]);
		int flen = flips.size();

		if (flen == 0 || flen > k) {
			error1("WA", "invalid flips length");
		}

		for (int i = 0; i < flen; i++) {
			if (flips[i] < 0 || flips[i] >= board_size) {
				error1("WA", "invalid coin index in flips");
			}
		}

		for (int i = 0; i < flen; i++) {
			int j = flips[i];
			bs[t][j] = 1 - bs[t][j];
		}
	}

	fprintf(pipe1, "%s\n", pipe_secret.c_str());
	fprintf(pipe1, "OK\n");
	fprintf(pipe1, "%d\n", tests); 
	for (int t = 0; t < tests; t++) {
		for (int i = 0; i < int(bs[t].size()); i++) {
			fprintf(pipe1, "%d", bs[t][i]);
		}
		fprintf(pipe1, "\n");
	}
	fclose(pipe1);
}

static void error2(string msg, string reason= "") {
	printf("%s\n", output_secret.c_str());
	printf("%s\n", msg.c_str());
	printf("%s\n", reason.c_str());
	fclose(stdout);
	exit(0);
}

static void pass2(char* pipe_path) {
	char secret[1000];
	// assert(1 == scanf("%s", secret));
	// if (string(secret) != input_secret) {
	//	 error2("SV");
	// }
	// fclose(stdin);

	FILE* pipe2 = fopen(pipe_path, "r");
	assert(1 == fscanf(pipe2, "%s", secret));
	if (string(secret) != pipe_secret) {
		error2("SV");
	}

	char status[1000];
	assert(1 == fscanf(pipe2, "%s\n", status));
	if (string(status) != "OK") {
		string reason = "";
		while (true) {
			int c = fgetc(pipe2);
			if (c == EOF || c=='\n')
				break;
			reason += char(c);
		}
		error2(status, reason);
	}

	int tests;
	assert(1 == fscanf(pipe2, "%d", &tests));

	vector<vector<int> > bs(tests);
	for (int t = 0; t < tests; t++) {
		bs[t].resize(board_size);
		char row[1000];
		assert(1 == fscanf(pipe2, "%s", row));
		for (int i = 0; i < board_size; i++) {
			bs[t][i] = int(row[i] - '0');
		}
	}
	fclose(pipe2);

	vector<int> p(tests);
	for (int t = 0; t < tests; t++) {
		p[t] = t;
	}
	shuffle(p);

	vector<int> coin(tests);
	for (int _t = 0; _t < tests; _t++) {
		int t = p[_t];
		coin[t] = find_coin(bs[t]);
	}

	printf("%s\n", output_secret.c_str());
	printf("OK\n");
	for (int t = 0; t < tests; t++) {
		printf("%d\n", coin[t]);
	}
}

int main(int argc, char **argv){
	if (argc < 3) {
		cout << "invalid arguments" << endl;
		return 1;
	}
	int type = atoi(argv[1]);
	if (type == 0) {
		pass1(argv[2]);
	} else {
		pass2(argv[2]);
	}
	return 0;
}



