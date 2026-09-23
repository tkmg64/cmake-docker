#!/bin/bash
#
# format.sh - clang-format を使用してソースコードを整形・検証するスクリプト
#
# 使い方:
# ./scripts/format.sh        # 全コードを一括フォーマット (apply)
# ./scripts/format.sh check  # フォーマット崩れがないか検証 (CI用: 差分があればエラー終了)
#

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-apply}"

TARGET_DIRS=("app")

# 対象拡張子: .cpp, .h, .hpp
find_source_files() {
  find "${TARGET_DIRS[@]}" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \)
}

case "$MODE" in
  apply)
    echo "--- コードフォーマットを一括適用しています ---"
    find_source_files | xargs -r clang-format -i
    echo "コードフォーマットの適用が完了しました。"
    ;;
  check)
    echo "--- コードフォーマットの検証を行っています ---"
    # --dry-run --Werror で差分があれば非ゼロ終了
    find_source_files | xargs -r clang-format --dry-run --Werror
    echo "コードフォーマットの検証に成功しました (差分なし)。"
    ;;
  *)
    echo "エラー: 不明なモード '$MODE'" >&2
    echo "使い方: $0 [apply|check]" >&2
    exit 1
    ;;
esac
