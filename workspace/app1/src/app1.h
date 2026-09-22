#pragma once

#include <cstdint>

/**
 * @file app1.h
 * @brief 算術演算モジュール (app1) の公開インターフェース定義
 * @author 開発チーム
 * @date 2026-09-22
 */

/**
 * @brief 2つの32ビット符号付き整数の加算を行います。
 *
 * @details
 * 引数 @p lhs と @p rhs の算術加算を計算し、その結果を返却します。
 * 内部処理において動的メモリ確保やブロッキングは行わず、
 * 高速かつ決定的な時間で処理を完了します。
 *
 * @pre 呼び出し元は、加算結果が 32 ビット符号付き整数の表現範囲
 *      [INT32_MIN, INT32_MAX] に収まることを保証すること。
 * @post 加算結果が正確に計算され、返却される。
 *
 * @param[in] lhs 左辺値 (Left-Hand Side) 加算対象の第1オペランド
 * @param[in] rhs 右辺値 (Right-Hand Side) 加算対象の第2オペランド
 *
 * @return std::int32_t 加算結果 (lhs + rhs)
 *
 * @note 設計メモ:
 *       - 環境非依存のため、基本型 int ではなく固定幅型 std::int32_t を使用。
 *       - 例外を送出しないため noexcept を明記。
 *       - 戻り値の確認漏れを防止するため [[nodiscard]] を付与。
 *
 * @see main1.cpp
 */
[[nodiscard]] std::int32_t add(std::int32_t lhs, std::int32_t rhs) noexcept;
