#include <algorithm>
#include <queue>
#include <cmath>
#include "testlib.h"
#define MAX (1024 + 64)
using namespace std;
int m, n, leaves, answer;
std::vector <std::string> maze;
bool mark[MAX][MAX];
int rplus[4] = {1, -1, 0, 0}, cplus[4] = {0, 0, 1, -1};
struct node {
	node(int _r, int _c, int _pr, int _pc) {
		r = _r; c = _c; pr = _pr; pc = _pc;
	}
	int r, c, pr, pc;
};

bool inside(int r, int c) {
	return r >= 0 && r < m && c >= 0 && c < n;
}

bool leaf(int r, int c) {
	int adj = 0;
	for (int i = 0; i < 4; i++)
		if (inside(r + rplus[i], c + cplus[i]) && maze[r + rplus[i]][c + cplus[i]] == '.') adj++;
	return adj == 1;
}

void BFS(int r, int c) {
	queue <node> Q;
	Q.push(node(r, c, -1, -1));
	mark[r][c] = true;
	while (! Q.empty()) {
		node v = Q.front();
		Q.pop();
		if (leaf(v.r, v.c)) leaves++;
		for (int i = 0; i < 4; i++) {
			int a = v.r + rplus[i], b = v.c + cplus[i];
			if (inside(a, b) && maze[a][b] == '.' && (a != v.pr || b != v.pc)) {
				if (mark[a][b]) quitf(_wa, "Output has cycle");
				Q.push(node(a, b, v.r, v.c));
				mark[a][b] = true;
			}
		}
	}
}

int main(int argc, char * argv[])
{
	registerChecker("nowruz", argc, argv);
	m = inf.readInt();
	inf.readSpace();
	n = inf.readInt();
	inf.readSpace();
	answer = inf.readInt();
	inf.readEoln();
	// Read input and output mazes, and comparing if they match
	for (int i = 0; i < m; i++) {
		string input = inf.readLine("[.#]{" + std::to_string(n) + "," + std::to_string(n) + "}");
		maze.push_back(ouf.readLine("[.#X]{" + std::to_string(n) + "," + std::to_string(n) + "}"));
		for (int j = 0; j < n; j++)
			if (input[j] != maze[i][j] && (input[j] != '.' || maze[i][j] != 'X'))
				quitf(_wa, "Input and output maps are different at cell [%d, %d]", i, j);
	}

	// Check if output maze is a tree, and count its leaves
	int component = 0;
	for (int i = 0; i < m; i++)
		for (int j = 0; j < n; j++)
			if (maze[i][j] == '.' && ! mark[i][j]) {
				if (component++ > 0) quitf(_wa, "Output maze is not connected");
				BFS(i, j);
			}

	double score = int(leaves / (double)answer * 1000) / 1000.0;

	if (abs(score) < 1e-5) quitf(_wa, "Your rounded-down score is 0");
	if (score < 1 - 1e-5) quitp(score, "number of leaves: %d/%d", leaves, answer);
	quitf(_ok, "number of leaves: %d/%d", leaves, answer);
}
