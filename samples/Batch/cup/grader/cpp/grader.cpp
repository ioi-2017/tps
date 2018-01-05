#include "cup.h"
#include <cstdio>
#include <string>
#include <cstdlib>
#include <cassert>
using namespace std;

// BEGIN SECRET
static const string input_secret = "e8a66651-560d-46a7-9496-0782b8bb7081";
static const string output_secret = "be6fe19e-6ee7-4837-a81e-6f6902743b31";

static const int codelen = 2;
static const int code[] = {0x971CBAB, 0x3C3D64EE};
static int crypt(int value, int pos) {
    return value ^ code[pos & (codelen-1)];
}
// END SECRET
static const int WORLD_SIZE = 1000 * 1000 * 1000;
static int t;
static vector<int> a, b, qc;

static void wrong_answer() {
    // BEGIN SECRET
    printf("%s\n", output_secret.c_str());
    printf("WA\n");
    // END SECRET
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
    // BEGIN SECRET
    dx = crypt(a[t], 0) - x;
    dy = crypt(b[t], 1) - y;
    // END SECRET
    return abs(dx) ^ abs(dy);
}

int main() {
    // BEGIN SECRET
    {
        char secret[1000];
        assert(1 == scanf("%s", secret));
        if (string(secret) != input_secret) {
            printf("%s\n", output_secret.c_str());
            printf("SV\n");
            exit(0);
        }
    }
    // END SECRET
    int tests;
    assert(1 == scanf("%d", &tests));
    a.resize(tests);
    b.resize(tests);
    qc.resize(tests);
    for (t = 0; t < tests; t++) {
        assert(2 == scanf("%d %d", &a[t], &b[t]));
        // BEGIN SECRET
        a[t] = crypt(a[t], 0);
        b[t] = crypt(b[t], 1);
        // END SECRET
    }
    for (t = 0; t < tests; t++) {
        qc[t] = 0;
        vector<int> result = find_cup();
        if (int(result.size()) != 2) {
            wrong_answer();
        }
        int x = a[t];
        int y = b[t];
        // BEGIN SECRET
        x = crypt(x, 0);
        y = crypt(y, 1);
        // END SECRET
        if (result[0] != x || result[1] != y) {
            qc[t] = -1;
        }
    }
    // BEGIN SECRET
    printf("%s\n", output_secret.c_str());
    printf("OK\n");
    // END SECRET
    for (t = 0; t < tests; t++) {
        printf("%d\n", qc[t]);
    }
    return 0;
}
