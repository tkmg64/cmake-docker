#!/bin/bash
#
# package.sh - 配布用ポータブルアーカイブ (.tar.gz) を生成するスクリプト (CPack)
#
# 使い方:
# ./package.sh
#

set -euo pipefail

cd "$(dirname "$0")"

BUILD_DIR="build_release"
DIST_DIR="dist"

echo "======================================================"
echo "  配布用アーカイブ (.tar.gz) の生成を開始します (CPack)"
echo "======================================================"

# 1. リリース用ビルドディレクトリの設定とビルド
echo ""
echo "--- [1/3] CMake Release ビルドを設定しています ---"
cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE=Release

echo ""
echo "--- [2/3] プロジェクトを並列コンパイルしています ---"
cmake --build "$BUILD_DIR" --parallel

# 出力先ディレクトリの準備
mkdir -p "$DIST_DIR"

# 2. CPack の実行 (TGZ)
echo ""
echo "--- [3/3] CPack で .tar.gz パッケージを生成しています ---"
cd "$BUILD_DIR"
cpack -G TGZ
cd ..

# 3. 生成されたアーカイブを dist/ ディレクトリに移動
echo ""
echo "--- アーカイブを '$DIST_DIR/' ディレクトリに集約しています ---"
find "$BUILD_DIR" -maxdepth 1 -name "*.tar.gz" -exec mv -v {} "$DIST_DIR/" \;

echo ""
echo "======================================================"
echo "  アーカイブの生成が完了しました！"
echo "  出力ディレクトリ: $(pwd)/$DIST_DIR"
echo "======================================================"
ls -lh "$DIST_DIR"
