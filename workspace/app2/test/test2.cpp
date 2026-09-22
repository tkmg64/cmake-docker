#include <gtest/gtest.h>

#include "app2.h"

// concatenate関数のテストケース
TEST(ConcatenateTest, Basic) {
    EXPECT_EQ("Hello World", concatenate("Hello", "World"));
}

TEST(ConcatenateTest, EmptyStrings) {
    EXPECT_EQ(" ", concatenate("", ""));
    EXPECT_EQ("Hello ", concatenate("Hello", ""));
}