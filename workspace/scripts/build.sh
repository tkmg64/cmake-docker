#!/bin/bash
#
# build.sh - プロジェクトのビルド用スクリプト (Ninja + CMake)
#
# 使い方:
# ./scripts/build.sh [Debug|Release] [--tidy]
#
# 引数なしの場合は Debug でビルドします。
# --tidy を指定すると、コンパイル時に clang-tidy 静的解析を並行実行します。
#

set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_TYPE="Debug"
ENABLE_TIDY="OFF"

for arg in "$@"; do
  case "$arg" in
    --tidy|-t)
      ENABLE_TIDY="ON"
      ;;
    Release|release)
      BUILD_TYPE="Release"
      ;;
    Debug|debug)
      BUILD_TYPE="Debug"
      ;;
    *)
      echo "エラー: 不明な引数 '$arg'" >&2
      echo "使い方: $0 [Debug|Release] [--tidy]" >&2
      exit 1
      ;;
  esac
done

case "${BUILD_TYPE}" in
  Release|release)
    BUILD_DIR="build/release"
    ;;
  *)
    BUILD_DIR="build/debug"
    ;;
esac

echo "--- CMakeを設定しています (BuildType: ${BUILD_TYPE}, Generator: Ninja, Clang-Tidy: ${ENABLE_TIDY}) ---"
cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DENABLE_CLANG_TIDY="${ENABLE_TIDY}"

echo ""
echo "--- プロジェクトを並列ビルドしています ---"
cmake --build "$BUILD_DIR" --parallel

echo ""
echo "ビルドが完了しました。"
echo "実行可能ファイルは './${BUILD_DIR}/app/app' にあります。"
