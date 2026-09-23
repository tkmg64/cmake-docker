#!/bin/bash
#
# test.sh - テスト、静的解析、メモリ解析、カバレッジ計測を実行する統合スクリプト
#
# 使い方:
# ./scripts/test.sh [unit|static|tidy|memory|asan|coverage|doc|format|format-check|package|all] [--strict]
#
# 引数なし or unit: ユニットテスト (ctest) を実行
# static:         静的解析 (cppcheck + clang-tidy) を実行
# tidy:           静的解析 (clang-tidy / MISRA C++:2023 参考ルール) を実行
# memory:         メモリ解析 (valgrind) を実行
# asan:           サニタイザ (AddressSanitizer / UndefinedBehaviorSanitizer) を実行
# coverage:       カバレッジ計測を実行
# doc:            Doxygen API ドキュメントを生成
# format:         コードフォーマットを一括適用
# format-check:   コードフォーマット崩れの有無を検証
# package:        配布用アーカイブ (.tar.gz) を生成
# all:            format-check, unit, static, memory, asan, coverage の全てのチェックを実行
#
# オプション:
# --strict:       静的解析で指摘・警告が1件でもあれば非ゼロ終了 (exit 1) します。
#                 (環境変数 STRICT_STATIC_CHECK=1 の指定でも同様に機能します)
#

set -euo pipefail
cd "$(dirname "$0")/.."

# ログディレクトリの定義と作成
LOG_DIR="build/reports/logs"
mkdir -p "$LOG_DIR"

# --- 関数定義 ---

# ビルドディレクトリの存在を確認し、なければビルドを実行
ensure_build() {
  if [ ! -d "build/debug" ]; then
    echo "ビルドディレクトリが見つかりません。./scripts/build.sh Debug を実行します..."
    ./scripts/build.sh Debug
  fi
}

# ユニットテストの実行
run_unit_test() {
  echo ""
  echo "----------------------------------------"
  echo "--- ユニットテストを実行しています ---"
  echo "----------------------------------------"
  ensure_build
  local log_file="$LOG_DIR/unit_test.log"
  ctest --test-dir build/debug --output-on-failure 2>&1 | tee "$log_file"
  echo "--> ユニットテストのログを保存しました: $log_file"
}

# 静的解析の警告件数カウンター
CPPCHECK_ISSUES=0
CLANG_TIDY_ISSUES=0
STRICT_STATIC_CHECK="${STRICT_STATIC_CHECK:-0}"

# 静的解析 (cppcheck) の実行
run_cppcheck() {
  echo ""
  echo "----------------------------------------"
  echo "--- 静的解析 (cppcheck) を実行しています ---"
  echo "----------------------------------------"
  local log_file="$LOG_DIR/static_check.log"

  # --template=gcc: VS Code / IDE の problemMatcher ($gcc) と完全互換の形式で出力
  # --suppress=unusedFunction: 公開関数やインターフェースの誤検知ノイズを抑制
  # --suppress=unmatchedSuppression: 未使用のsuppress指定に対する警告を抑制
  # --suppress=checkersReport: チェッカー一覧の通知行を抑制
  # --inline-suppr: ソースコード内の // cppcheck-suppress コメントでの個別抑制を許可
  cppcheck --enable=all \
    --template=gcc \
    --suppress=missingIncludeSystem \
    --suppress=unusedFunction \
    --suppress=unmatchedSuppression \
    --suppress=checkersReport \
    --inline-suppr \
    -I app/include \
    app/include app/src 2>&1 | tee "$log_file"
  echo "--> cppcheck のログを保存しました: $log_file"

  # 指摘・警告行の集計 (エラー, 警告, スタイル, パフォーマンス, 移植性 / nofileは除外)
  CPPCHECK_ISSUES=$(grep -v '^nofile:' "$log_file" | grep -c -E ':[0-9]+:[0-9]+: (warning|error|style|performance|portability):' || true)

  echo ""
  if [ "$CPPCHECK_ISSUES" -gt 0 ]; then
    echo -e "\033[1;33m⚠️  [cppcheck] ${CPPCHECK_ISSUES} 件の指摘が検出されました！\033[0m"
    echo "--- 主な指摘抜粋 (最大10件) ---"
    grep -v '^nofile:' "$log_file" | grep -E ':[0-9]+:[0-9]+: (warning|error|style|performance|portability):' | head -n 10
  else
    echo -e "\033[1;32m✅ [cppcheck] 指摘・警告はありません。\033[0m"
  fi
}

# 静的解析 (clang-tidy: MISRA C++:2023 / AUTOSAR / CERT などを参考にしたルール) の実行
run_clang_tidy() {
  echo ""
  echo "--------------------------------------------------------"
  echo "--- 静的解析 (clang-tidy: MISRA C++:2023 参考) を実行しています ---"
  echo "--------------------------------------------------------"
  ensure_build
  local log_file="$LOG_DIR/clang_tidy.log"
  
  # compile_commands.json を利用してソースコードをチェック (app/src 配下の全cppファイルを自動検出)
  local source_files=()
  while IFS= read -r file; do
    source_files+=("$file")
  done < <(find app/src -type f -name "*.cpp" | sort)

  if [ ${#source_files[@]} -eq 0 ]; then
    echo "対象の C++ ソースファイルが見つかりませんでした。"
    return 0
  fi
  
  clang-tidy -p build/debug "${source_files[@]}" 2>&1 | tee "$log_file"
  echo "--> clang-tidy のログを保存しました: $log_file"

  # 警告・エラー行の集計
  CLANG_TIDY_ISSUES=$(grep -c -E ':[0-9]+:[0-9]+: (warning|error):' "$log_file" || true)

  echo ""
  if [ "$CLANG_TIDY_ISSUES" -gt 0 ]; then
    echo -e "\033[1;33m⚠️  [clang-tidy] ${CLANG_TIDY_ISSUES} 件の警告が検出されました！\033[0m"
    echo "--- 主な警告抜粋 (最大10件) ---"
    grep -E ':[0-9]+:[0-9]+: (warning|error):' "$log_file" | head -n 10
  else
    echo -e "\033[1;32m✅ [clang-tidy] 警告はありません。\033[0m"
  fi
}

# 静的解析の統合実行 (cppcheck + clang-tidy)
run_static_check() {
  run_cppcheck
  run_clang_tidy

  local total_issues=$((CPPCHECK_ISSUES + CLANG_TIDY_ISSUES))
  echo ""
  echo "========================================================"
  echo "===              静的解析サマリー                     ==="
  echo "========================================================"
  if [ "$total_issues" -gt 0 ]; then
    echo -e "\033[1;33m⚠️  静的解析で合計 ${total_issues} 件の指摘が検出されました！ (cppcheck: ${CPPCHECK_ISSUES}, clang-tidy: ${CLANG_TIDY_ISSUES})\033[0m"
    echo -e "\033[1;33m    詳細ログ: $LOG_DIR/static_check.log , $LOG_DIR/clang_tidy.log\033[0m"
    if [ "$STRICT_STATIC_CHECK" = "1" ]; then
      echo -e "\033[1;31m❌ 厳格モード (STRICT_STATIC_CHECK=1) 有効のため、エラー終了します。\033[0m"
      exit 1
    fi
  else
    echo -e "\033[1;32m✅ 静的解析 (cppcheck / clang-tidy) の指摘・警告はありません。\033[0m"
  fi
  echo "========================================================"
}

# メモリ解析の実行
run_memory_check() {
  echo ""
  echo "----------------------------------------"
  echo "--- メモリ解析 (valgrind) を実行しています ---"
  echo "----------------------------------------"
  ensure_build
  local log_file="$LOG_DIR/memory_check.log"
  {
    echo "=== Valgrind: app_test ==="
    valgrind --leak-check=full --show-leak-kinds=all ./build/debug/app/app_test
  } 2>&1 | tee "$log_file"
  echo "--> メモリ解析のログを保存しました: $log_file"
}

# サニタイザ (AddressSanitizer / UndefinedBehaviorSanitizer) の実行
run_sanitizer() {
  echo ""
  echo "--------------------------------------------------------"
  echo "--- サニタイザ (ASan / UBSan) テストを実行しています ---"
  echo "--------------------------------------------------------"
  local log_file="$LOG_DIR/sanitizer.log"
  {
    echo "--- ASan/UBSan 用ビルドを実行中 ---"
    cmake --preset asan
    cmake --build --preset asan --parallel

    echo ""
    echo "--- サニタイザ有効下でテストを実行中 ---"
    export ASAN_OPTIONS="symbolize=1:detect_leaks=1:abort_on_error=1"
    export UBSAN_OPTIONS="print_stacktrace=1:abort_on_error=1"
    ctest --preset asan --output-on-failure
  } 2>&1 | tee "$log_file"
  echo "--> サニタイザテストのログを保存しました: $log_file"
}

# カバレッジ計測の実行
run_coverage() {
  echo ""
  echo "----------------------------------------"
  echo "--- カバレッジ計測を実行しています ---"
  echo "----------------------------------------"
  
  BUILD_DIR="build/coverage"
  OUTPUT_DIR="build/reports/coverage"
  local log_file="$LOG_DIR/coverage.log"

  if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
  fi

  {
    echo "--- カバレッジモードでCMakeを実行・並列ビルドしています ---"
    cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE=Coverage
    cmake --build "$BUILD_DIR" --parallel

    echo ""
    echo "--- カバレッジカウンタをリセットしています ---"
    lcov --zerocounters --directory "$BUILD_DIR"

    echo ""
    echo "--- テストを実行してカバレッジデータを生成しています ---"
    ctest --test-dir "$BUILD_DIR" --output-on-failure

    echo ""
    echo "--- lcovでカバレッジデータを収集しています ---"
    lcov --capture --directory "$BUILD_DIR" --output-file "$BUILD_DIR/coverage.info" --ignore-errors mismatch,unused

    echo ""
    echo "--- テストコードと外部ライブラリをカバレッジから除外しています ---"
    lcov --remove "$BUILD_DIR/coverage.info" \
         '/usr/*' \
         '*/_deps/*' \
         '*/test/*' \
         '*/src/main*.cpp' \
         --output-file "$BUILD_DIR/coverage.final.info" \
         --ignore-errors unused,unused

    if [ -d "$OUTPUT_DIR" ]; then
      rm -rf "$OUTPUT_DIR"
    fi
    echo ""
    echo "--- genhtmlでHTMLレポートを生成しています ---"
    genhtml "$BUILD_DIR/coverage.final.info" --output-directory "$OUTPUT_DIR" --ignore-errors unmapped
  } 2>&1 | tee "$log_file"

  echo ""
  echo "カバレッジレポートの生成が完了しました。"
  echo "ブラウザで '$OUTPUT_DIR/index.html' を開いて確認してください。"
  echo "--> カバレッジログを保存しました: $log_file"
}

# --- メイン処理 ---

filtered_args=()
for arg in "$@"; do
  if [ "$arg" = "--strict" ]; then
    STRICT_STATIC_CHECK=1
  else
    filtered_args+=("$arg")
  fi
done

if [ ${#filtered_args[@]} -eq 0 ]; then
  run_unit_test
  echo ""
  echo "ユニットテストが完了しました。 (ログディレクトリ: $LOG_DIR/)"
  exit 0
fi

for arg in "${filtered_args[@]}"; do
  case "$arg" in
    unit)
      run_unit_test
      ;;
    static)
      run_static_check
      ;;
    tidy)
      run_clang_tidy
      if [ "$CLANG_TIDY_ISSUES" -gt 0 ] && [ "$STRICT_STATIC_CHECK" = "1" ]; then
        echo -e "\033[1;31m❌ 厳格モード (STRICT_STATIC_CHECK=1) 有効のため、エラー終了します。\033[0m"
        exit 1
      fi
      ;;
    memory)
      run_memory_check
      ;;
    asan)
      run_sanitizer
      ;;
    coverage)
      run_coverage
      ;;
    doc)
      ./scripts/doc.sh
      ;;
    format)
      ./scripts/format.sh apply
      ;;
    format-check)
      ./scripts/format.sh check
      ;;
    package)
      ./scripts/package.sh all
      ;;
    all)
      ./scripts/format.sh check
      run_unit_test
      run_static_check
      run_memory_check
      run_sanitizer
      run_coverage
      ;;
    *)
      echo "エラー: 不明な引数 '$arg'" >&2
      echo "使い方: $0 [unit|static|tidy|memory|asan|coverage|doc|format|format-check|package|all] [--strict]" >&2
      exit 1
      ;;
  esac
done

echo ""
echo "指定されたチェックが完了しました。 (ログディレクトリ: $LOG_DIR/)"
