#include <iostream>
#include <string>

#include "app2.h"

int main() {
    const std::string result = concatenate("Hello", "World");
    std::cout << "app2: " << result << '\n';
    return 0;
}