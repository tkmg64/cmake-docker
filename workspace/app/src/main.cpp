/**
 * @file main.cpp
 * @brief app アプリケーションのエントリーポイント
 */

#include <cstdint>
#include <iostream>

#include "app/math/add.h"

/**
 * @brief app のメイン関数
 * @return int 終了ステータス (常に 0)
 */
int main() {
    std::cout << "app is starting up...\n";
    const std::int32_t result = add(2, 3);
    std::cout << "app: 2 + 3 = " << result << '\n';
    return 0;
}