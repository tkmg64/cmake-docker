#pragma once

#include <string>
#include <string_view>

// 文字列を連結する関数 (MISRA C++:2023: string_view による効率的かつ安全な参照、戻り値チェック属性)
[[nodiscard]] std::string concatenate(std::string_view first, std::string_view second);
