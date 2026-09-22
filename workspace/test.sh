#!/bin/bash
#
# test.sh - テスト、静的解析、メモリ解析、カバレッジ計測を実行する統合スクリプト
#
# 使い方:
# ./test.sh [unit|static|tidy|memory|asan|coverage|doc|format|format-check|package|all]
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

set -euo pipefail
cd "$(dirname "$0")"

# ログディレクトリの定義と作成
LOG_DIR="test_logs"
mkdir -p "$LOG_DIR"

# --- 関数定義 ---

# ビルドディレクトリの存在を確認し、なければビルドを実行
ensure_build() {
  if [ ! -d "build" ]; then
    echo "ビルドディレクトリが見つかりません。./build.sh を実行します..."
    ./build.sh
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
  ctest --test-dir build --output-on-failure 2>&1 | tee "$log_file"
  echo "--> ユニットテストのログを保存しました: $log_file"
}

# 静的解析 (cppcheck) の実行
run_cppcheck() {
  echo ""
  echo "----------------------------------------"
  echo "--- 静的解析 (cppcheck) を実行しています ---"
  echo "----------------------------------------"
  local log_file="$LOG_DIR/static_check.log"
  cppcheck --enable=all --suppress=missingIncludeSystem app1/src app2/src 2>&1 | tee "$log_file"
  echo "--> cppcheck のログを保存しました: $log_file"
}

# 静的解析 (clang-tidy: MISRA C++:2023 / AUTOSAR / CERT などを参考にしたルール) の実行
run_clang_tidy() {
  echo ""
  echo "--------------------------------------------------------"
  echo "--- 静的解析 (clang-tidy: MISRA C++:2023 参考) を実行しています ---"
  echo "--------------------------------------------------------"
  ensure_build
  local log_file="$LOG_DIR/clang_tidy.log"
  
  # compile_commands.json を利用してソースコードをチェック
  local source_files=(
    app1/src/app1.cpp
    app1/src/main1.cpp
    app2/src/app2.cpp
    app2/src/main2.cpp
  )
  
  clang-tidy -p build "${source_files[@]}" 2>&1 | tee "$log_file"
  echo "--> clang-tidy のログを保存しました: $log_file"
}

# 静的解析の統合実行 (cppcheck + clang-tidy)
run_static_check() {
  run_cppcheck
  run_clang_tidy
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
    echo "=== Valgrind: app1_test ==="
    valgrind --leak-check=full --show-leak-kinds=all ./build/app1/app1_test
    echo ""
    echo "=== Valgrind: app2_test ==="
    valgrind --leak-check=full --show-leak-kinds=all ./build/app2/app2_test
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
  
  BUILD_DIR="build_coverage"
  OUTPUT_DIR="coverage_report"
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

if [ $# -eq 0 ]; then
  run_unit_test
  echo ""
  echo "ユニットテストが完了しました。 (ログディレクトリ: $LOG_DIR/)"
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    unit)
      run_unit_test
      ;;
    static)
      run_static_check
      ;;
    tidy)
      run_clang_tidy
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
      ./doc.sh
      ;;
    format)
      ./format.sh apply
      ;;
    format-check)
      ./format.sh check
      ;;
    package)
      ./package.sh all
      ;;
    all)
      ./format.sh check
      run_unit_test
      run_static_check
      run_memory_check
      run_sanitizer
      run_coverage
      ;;
    *)
      echo "エラー: 不明な引数 '$arg'" >&2
      echo "使い方: $0 [unit|static|tidy|memory|asan|coverage|doc|format|format-check|package|all]" >&2
      exit 1
      ;;
  esac
done

echo ""
echo "指定されたチェックが完了しました。 (ログディレクトリ: $LOG_DIR/)"
