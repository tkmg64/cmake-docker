#include "func.h"

#include <iostream>
#include <vector>
#include <boost/range/algorithm.hpp>
#include <boost/range/irange.hpp>

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


void func4_boost_test() {
  std::cout << "func4_boost_test called" << std::endl;
    std::vector<int> a = {1, 2, 3};
  std::vector<char> b = {'A', 'B'};

  boost::for_each(a, [&](int x) {
    boost::for_each(b, [&](char y) {
      std::cout << "(" << x << ", " << y << ")" << std::endl;
    });
  });
}
