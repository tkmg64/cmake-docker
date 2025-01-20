#include <gtest/gtest.h>

#include "../src/func.h"

TEST(test_func, initialize) {
  // test code
  std::cout << "test_func called" << std::endl;
  func();
  std::cout << "test_func end" << std::endl;
  EXPECT_EQ(1, 1);
}

TEST(test_func, func2) {
  func2(1, 2);
  EXPECT_EQ(1, 1);
}

TEST(test_func, func3_memory_leak) {
  func3_memory_leak();
  EXPECT_EQ(1, 1);
}

TEST(test_func, func4_boost_test) {
  func4_boost_test();
  EXPECT_EQ(1, 1);
}