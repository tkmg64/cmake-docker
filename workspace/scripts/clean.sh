#!/bin/bash
#
# clean.sh - ビルド成果物とレポートを削除するスクリプト
#
# 使い方:
# ./scripts/clean.sh
#

set -euo pipefail
cd "$(dirname "$0")/.."

echo "--- クリーンアップを開始します ---"

# 削除対象のディレクトリを定義 (集約先 build/ および旧ディレクトリ)
TARGET_DIRS=(
  "build"
  "build_release"
  "build_coverage"
  "build_asan"
  "coverage_report"
  "test_logs"
  "docs"
  "dist"
)

for dir in "${TARGET_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "'$dir' ディレクトリを削除します..."
    rm -rf "$dir"
  else
    echo "'$dir' ディレクトリは見つかりませんでした。"
  fi
done

echo ""
echo "クリーンアップが完了しました。"