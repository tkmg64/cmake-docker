#include "func.h"

#include <iostream>

void func() {
  std::cout << "func called" << std::endl;
}

void func2(int a, int b) {
  std::cout << "func2 called" << std::endl;
  if (a > b) {
    std::cout << "a is greater than b" << std::endl;
  } else {
    std::cout << "a is less than or equal to b" << std::endl;
  }
}

void func3_memory_leak() {
  int* ptr = new int[10];
  // メモリリークを引き起こすために、ポインタを解放しない
}