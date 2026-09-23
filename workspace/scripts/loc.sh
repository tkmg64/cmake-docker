#!/bin/bash
#
# loc.sh - cloc を使用してソースコード行数 (ステップ数) および KL数を計測するスクリプト
#
# 使い方:
# ./scripts/loc.sh           # デフォルト (app ディレクトリ) を計測
# ./scripts/loc.sh <path>... # 指定したディレクトリやファイルを計測
#
# 出力:
# コンソール出力および build/reports/logs/ 配下にレポートを出力します。
# - build/reports/logs/cloc.log  (テキストレポート)
# - build/reports/logs/cloc.json (JSON 形式レポート)
#

set -euo pipefail
cd "$(dirname "$0")/.."

LOG_DIR="build/reports/logs"
mkdir -p "$LOG_DIR"

# cloc コマンドの存在確認
if ! command -v cloc &> /dev/null; then
  echo -e "\033[1;31mエラー: cloc が見つかりません。\033[0m" >&2
  echo "Docker コンテナ内で実行するか、'docker compose build' で最新イメージをリビルドしてください。" >&2
  exit 1
fi

# 計測対象パスの設定 (引数指定がなければ app ディレクトリ、存在しなければカレントディレクトリ)
TARGET_PATHS=("$@")
if [ ${#TARGET_PATHS[@]} -eq 0 ]; then
  if [ -d "app" ]; then
    TARGET_PATHS=("app")
  else
    TARGET_PATHS=(".")
  fi
fi

echo "========================================================"
echo "--- コード規模・行数計測 (cloc) を実行しています ---"
echo "--- 対象: ${TARGET_PATHS[*]}"
echo "========================================================"

LOG_FILE="$LOG_DIR/cloc.log"
JSON_FILE="$LOG_DIR/cloc.json"

# テキスト形式でログ保存しつつ画面出力
# ビルド生成物、VS Code 設定、Git 管理ディレクトリ等を除外
cloc "${TARGET_PATHS[@]}" \
  --exclude-dir=build,.vscode,.git,doxygen \
  --report-file="$LOG_FILE"

cat "$LOG_FILE"

# JSON 形式でもレポートを保存 (CI / 外部ツール連携用)
cloc "${TARGET_PATHS[@]}" \
  --exclude-dir=build,.vscode,.git,doxygen \
  --json \
  --report-file="$JSON_FILE" > /dev/null 2>&1 || true

# レポートから集計数値を抽出
TOTAL_FILES=$(awk '/^SUM:/ {print $2}' "$LOG_FILE" || true)
TOTAL_BLANK=$(awk '/^SUM:/ {print $3}' "$LOG_FILE" || true)
TOTAL_COMMENT=$(awk '/^SUM:/ {print $4}' "$LOG_FILE" || true)
TOTAL_CODE=$(awk '/^SUM:/ {print $5}' "$LOG_FILE" || true)

if [ -n "$TOTAL_CODE" ] && [ "$TOTAL_CODE" -gt 0 ] 2>/dev/null; then
  TOTAL_LINES=$((TOTAL_BLANK + TOTAL_COMMENT + TOTAL_CODE))
  KL_CODE=$(awk "BEGIN {printf \"%.3f\", $TOTAL_CODE / 1000}")
  KL_TOTAL=$(awk "BEGIN {printf \"%.3f\", $TOTAL_LINES / 1000}")

  echo ""
  echo "========================================================"
  echo -e "📊 \033[1;36mコード規模 (KL数 / KLOC) サマリー\033[0m"
  echo "========================================================"
  echo -e "  ・対象ファイル数 : \033[1m${TOTAL_FILES}\033[0m ファイル"
  echo -e "  ・実コード行数   : \033[1;32m${TOTAL_CODE}\033[0m 行 (\033[1;32m${KL_CODE} KL\033[0m / KLOC)"
  echo -e "  ・コメント行数   : ${TOTAL_COMMENT} 行"
  echo -e "  ・空行数         : ${TOTAL_BLANK} 行"
  echo -e "  ・総行数         : ${TOTAL_LINES} 行 (${KL_TOTAL} KL)"
  echo "--------------------------------------------------------"
  echo "  --> テキストレポート : $LOG_FILE"
  echo "  --> JSON レポート    : $JSON_FILE"
  echo "========================================================"
else
  echo ""
  echo "対象ファイルが見つかりませんでした。"
fi
