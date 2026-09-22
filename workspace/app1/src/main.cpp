/**
 * @file main.cpp
 * @brief app1 アプリケーションのエントリーポイント
 */

#include <cstdint>
#include <iostream>

#include "app1/math/add.h"

/**
 * @brief app1 のメイン関数
 * @return int 終了ステータス (常に 0)
 */
int main() {
    const std::int32_t result = add(2, 3);
    std::cout << "app1: 2 + 3 = " << result << '\n';
    return 0;
}