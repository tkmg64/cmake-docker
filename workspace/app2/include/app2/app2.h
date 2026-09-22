#pragma once

#include <string>
#include <string_view>

/**
 * @file app2.h
 * @brief 文字列処理モジュール (app2) の公開インターフェース定義
 * @author 開発チーム
 * @date 2026-09-22
 */

/**
 * @brief 2つの文字列を半角スペースで連結した新しい文字列を生成します。
 *
 * @details
 * 2つの文字列参照 @p first および @p second の間に半角スペース (' ') を挟んで連結し、
 * 新たな `std::string` オブジェクトとして返却します。
 * 内部では `reserve` を用いて必要なメモリ領域（first.size() + 1 + second.size()）を
 * 事前に一括確保することで、動的再アロケーションの発生を抑止し、メモリ効率と実行速度を最適化しています。
 *
 * @pre @p first および @p second は有効な文字列領域を参照していること。
 * @post 戻り値の文字列長は `first.size() + second.size() + 1` となる。
 *
 * @param[in] first  連結対象の第1文字列 (参照渡し、コピーなし)
 * @param[in] second 連結対象の第2文字列 (参照渡し、コピーなし)
 *
 * @return std::string 連結後の新規文字列 ("<first> <second>")
 *
 * @note 設計メモ:
 *       - 引数に std::string_view を使用し、不要な一時オブジェクト生成やヒープ確保を回避。
 *       - 戻り値の確認漏れを防止するため [[nodiscard]] を付与。
 *
 * @see main.cpp
 */
[[nodiscard]] std::string concatenate(std::string_view first, std::string_view second);
