#!/bin/bash
#
# test.sh - テスト、静的解析、メモリ解析、カバレッジ計測を実行する統合スクリプト
#
# 使い方:
# ./test.sh [unit|static|memory|coverage|all]
#
# 引数なし or unit: ユニットテスト (ctest) を実行
# static:         静的解析 (cppcheck) を実行
# memory:         メモリ解析 (valgrind) を実行
# coverage:       カバレッジ計測を実行
# all:            unit, static, memory, coverage の全てのチェックを実行
#

set -euo pipefail
cd "$(dirname "$0")"

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
  cd build
  ctest --verbose
  cd ..
}

# 静的解析の実行
run_static_check() {
  echo ""
  echo "----------------------------------------"
  echo "--- 静的解析 (cppcheck) を実行しています ---"
  echo "----------------------------------------"
  cppcheck --enable=all --suppress=missingIncludeSystem app1/src app2/src
}

# メモリ解析の実行
run_memory_check() {
  echo ""
  echo "----------------------------------------"
  echo "--- メモリ解析 (valgrind) を実行しています ---"
  echo "----------------------------------------"
  ensure_build
  cd build
  echo "--- Valgrind: app1_test ---"
  valgrind --leak-check=full --show-leak-kinds=all ./app1/app1_test
  echo ""
  echo "--- Valgrind: app2_test ---"
  valgrind --leak-check=full --show-leak-kinds=all ./app2/app2_test
  cd ..
}

# カバレッジ計測の実行
run_coverage() {
    echo ""
    echo "----------------------------------------"
    echo "--- カバレッジ計測を実行しています ---"
    echo "----------------------------------------"
    
    BUILD_DIR="build_coverage"
    OUTPUT_DIR="coverage_report"

    if [ -d "$BUILD_DIR" ]; then
      echo "古いカバレッジビルドディレクトリ '$BUILD_DIR' を削除します..."
      rm -rf "$BUILD_DIR"
    fi
    mkdir "$BUILD_DIR"
    cd "$BUILD_DIR"

    echo "--- カバレッジモードでCMakeを実行しています ---"
    cmake -DCMAKE_BUILD_TYPE=Coverage ..
    echo "--- プロジェクトをビルドしています ---"
    make

    echo "--- カバレッジカウンタをリセットしています ---"
    lcov --zerocounters --directory .
    echo "--- テストを実行してカバレッジデータを生成しています ---"
    ./app1/app1_test
    ./app2/app2_test

    echo "--- lcovでカバレッジデータを収集しています ---"
    lcov --capture --directory . --output-file coverage.info

    cd .. # プロジェクトルートに戻る
    echo "--- テストコードと外部ライブラリをカバレッジから除外しています ---"
    lcov --ignore-errors unused --remove "$BUILD_DIR/coverage.info" \
         '/usr/*' \
         '*/_deps/*' \
         '*/test/*' \
         '*/src/main*.cpp' \
         --output-file "$BUILD_DIR/coverage.final.info"

    if [ -d "$OUTPUT_DIR" ]; then
      rm -rf "$OUTPUT_DIR"
    fi
    echo "--- genhtmlでHTMLレポートを生成しています ---"
    genhtml "$BUILD_DIR/coverage.final.info" --output-directory "$OUTPUT_DIR"

    echo ""
    echo "カバレッジレポートの生成が完了しました。"
    echo "ブラウザで '$OUTPUT_DIR/index.html' を開いて確認してください。"
}


# --- メイン処理 ---

# 引数が指定されていない場合は、ユニットテストを実行
if [ $# -eq 0 ]; then
  run_unit_test
  echo ""
  echo "ユニットテストが完了しました。"
  exit 0
fi

# 指定された引数に基づいてチェックを実行
for arg in "$@"; do
  case "$arg" in
    unit)
      run_unit_test
      ;;
    static)
      run_static_check
      ;;
    memory)
      run_memory_check
      ;;
    coverage)
      run_coverage
      ;;
    all)
      run_unit_test
      run_static_check
      run_memory_check
      run_coverage
      ;;
    *)
      echo "エラー: 不明な引数 '$arg'" >&2
      echo "使い方: $0 [unit|static|memory|coverage|all]" >&2
      exit 1
      ;;
  esac
done

echo ""
echo "指定されたチェックが完了しました。"
