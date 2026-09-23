/**
 * @file main.cpp
 * @brief app1 アプリケーションのエントリーポイント
 */

#include <spdlog/spdlog.h>

#include <cstdint>
#include <iostream>

#include "app1/math/add.h"

/**
 * @brief app1 のメイン関数
 * @return int 終了ステータス (常に 0)
 */
int main() {
    spdlog::info("app1 is starting up...");
    const std::int32_t result = add(2, 3);
    spdlog::info("app1: 2 + 3 = {}", result);
    std::cout << "app1: 2 + 3 = " << result << '\n';
    return 0;
}