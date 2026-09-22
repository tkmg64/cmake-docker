#!/bin/bash
#
# build.sh - プロジェクトのビルド用スクリプト (Ninja + CMake)
#
# 使い方:
# ./build.sh [Debug|Release]
# 引数なしの場合は Debug でビルドします。
#

set -euo pipefail

cd "$(dirname "$0")"

BUILD_TYPE="${1:-Debug}"
BUILD_DIR="build"

echo "--- CMakeを設定しています (BuildType: ${BUILD_TYPE}, Generator: Ninja) ---"
cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

echo ""
echo "--- プロジェクトを並列ビルドしています ---"
cmake --build "$BUILD_DIR" --parallel

echo ""
echo "ビルドが完了しました。"
echo "実行可能ファイルは './${BUILD_DIR}/app1/app1' と './${BUILD_DIR}/app2/app2' にあります。"
