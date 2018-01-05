#include "cup.h"

std::vector<int> find_cup() {
    std::vector<int> result(2);
    if (ask_shahrasb(0, 0) < ask_shahrasb(1, 2)) {
        result[0] = 0;
        result[1] = 0;
    } else {
        result[0] = 1;
        result[1] = 2;
    }
    return result;
}
