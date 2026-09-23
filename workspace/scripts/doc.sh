#!/bin/bash
#
# doc.sh - Doxygen API ドキュメントを生成するスクリプト
#
# 使い方:
# ./scripts/doc.sh
#

set -euo pipefail
cd "$(dirname "$0")/.."

DOCS_DIR="build/reports/docs/html"

echo "--- Doxygen API ドキュメントを生成しています ---"
if ! command -v doxygen &> /dev/null; then
  echo "エラー: doxygen コマンドが見つかりません。コンテナを再ビルドしてください。" >&2
  exit 1
fi

doxygen doxygen/Doxyfile

echo ""
echo "API ドキュメントの生成が完了しました。"
echo "ホストマシンのブラウザで '${DOCS_DIR}/index.html' を開いて確認してください。"
