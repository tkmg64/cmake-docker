/**
 * @file main.cpp
 * @brief app2 アプリケーションのエントリーポイント
 */

#include <iostream>
#include <string>

#include "app2/app2.h"

/**
 * @brief app2 のメイン関数
 * @return int 終了ステータス (常に 0)
 */
int main() {
    const std::string result = concatenate("Hello", "World");
    std::cout << "app2: " << result << '\n';
    return 0;
}