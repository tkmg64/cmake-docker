#!/bin/bash
#
# clean.sh - ビルド成果物とレポートを削除するスクリプト
#
# 使い方:
# 1. このファイルをプロジェクトのルートディレクトリに `clean.sh` として保存します。
# 2. 実行権限を付与します: chmod +x clean.sh
# 3. スクリプトを実行します: ./clean.sh
#

set -euo pipefail
cd "$(dirname "$0")"

echo "--- クリーンアップを開始します ---"

# 削除対象のディレクトリを定義
TARGET_DIRS=(
  "build"
  "build_coverage"
  "coverage_report"
  "test_logs"
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