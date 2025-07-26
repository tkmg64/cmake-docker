#include <iostream>

#include "app2.h"

int main() {
  std::string result = concatenate("Hello", "World");
  std::cout << "app2: " << result << std::endl;
  return 0;
}