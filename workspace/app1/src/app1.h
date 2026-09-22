#pragma once

#include <cstdint>

// 足し算を行う関数 (MISRA C++:2023: 明示的な固定幅整数型と例外安全性、戻り値チェック属性)
[[nodiscard]] std::int32_t add(std::int32_t lhs, std::int32_t rhs) noexcept;
