#include <cstdint>
#include <iostream>

#include "app1.h"

int main() {
    const std::int32_t result = add(2, 3);
    std::cout << "app1: 2 + 3 = " << result << '\n';
    return 0;
}