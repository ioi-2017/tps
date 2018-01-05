#include "cup.h"
#include <cstdio>
#include <string>
#include <cstdlib>
#include <cassert>
using namespace std;

static const int WORLD_SIZE = 1000 * 1000 * 1000;
static int t;
static vector<int> a, b, qc;

static void wrong_answer() {
    printf("%d\n", -1);
    exit(0);
}

int ask_shahrasb(int x, int y) {
    qc[t]++;
    if (abs(x) > WORLD_SIZE || abs(y) > WORLD_SIZE) {
        wrong_answer();
    }
    int dx = a[t] - x;
    int dy = b[t] - y;
    return abs(dx) ^ abs(dy);
}

int main() {
    int tests;
    assert(1 == scanf("%d", &tests));
    a.resize(tests);
    b.resize(tests);
    qc.resize(tests);
    for (t = 0; t < tests; t++) {
        assert(2 == scanf("%d %d", &a[t], &b[t]));
    }
    for (t = 0; t < tests; t++) {
        qc[t] = 0;
        vector<int> result = find_cup();
        if (int(result.size()) != 2) {
            wrong_answer();
        }
        int x = a[t];
        int y = b[t];
        if (result[0] != x || result[1] != y) {
            qc[t] = -1;
        }
    }
    for (t = 0; t < tests; t++) {
        printf("%d\n", qc[t]);
    }
    return 0;
}
