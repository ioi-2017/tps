#include "prize.h"

#include <iostream>
#include <vector>
#include <algorithm>
#include <fstream>
#include <cassert>

using namespace std;

static FILE *fin;
static FILE *fout;

vector<int> ask(int i) {
    fprintf(fout, "A %d\n", i);
    fflush(fout);
    vector<int> result(2);
    if (fscanf(fin, "%d %d", &result[0], &result[1]) != 2) {
        cerr << "tester error" << endl;
        cerr << "could not read query response" << endl;
        exit(0);
    }
    if (result[0] < 0) {
        exit(0);
    }
    return result;
}

int main(int argc, char **argv) {
    if(argc!=3) {
        cerr << "grader error" << endl;
        cerr << "number of argument isn't 3" << endl;
        exit(0);
    }
    fin = fopen(argv[1], "r11");
    fout = fopen(argv[2], "a");

    int n;
    if (fscanf(fin, "%d", &n) != 1) {
        cerr << "tester error" << endl;
        cerr << "could not read 'n'" << endl;
        exit(0);
    }

    int result = find_best(n);
    fprintf(fout, "B %d\n", result);
    fflush(fout);
    return 0;
}
