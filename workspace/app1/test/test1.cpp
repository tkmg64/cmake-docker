#include <gtest/gtest.h>

#include "../src/app1.h"  // テスト対象のヘッダー

// add関数のテストケース
TEST(AddTest, PositiveNumbers) {
  EXPECT_EQ(5, add(2, 3));
  EXPECT_EQ(100, add(50, 50));
}

TEST(AddTest, NegativeNumbers) { EXPECT_EQ(-5, add(-2, -3)); }