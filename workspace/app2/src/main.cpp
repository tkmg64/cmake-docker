/**
 * @file main.cpp
 * @brief app2 アプリケーションのエントリーポイント
 */

#include <spdlog/spdlog.h>

#include <iostream>
#include <string>

#include "app2/app2.h"

/**
 * @brief app2 のメイン関数
 * @return int 終了ステータス (常に 0)
 */
int main() {
    spdlog::info("app2 is starting up...");
    const std::string result = concatenate("Hello", "World");
    spdlog::info(R"(app2: concatenate("Hello", "World") = {})", result);
    std::cout << "app2: " << result << '\n';
    return 0;
}