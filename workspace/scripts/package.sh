#!/bin/bash
#
# package.sh - 配布用アーカイブ (.tar.gz) を生成するスクリプト (CPack)
#
# 使い方:
#   ./scripts/package.sh [all|source|bin]
#     all    : バイナリとソースアーカイブの両方を生成 (デフォルト)
#     source : Yocto (BitBake) 向けのソースアーカイブのみを高速生成
#     bin    : 実行可能バイナリ配布用のアーカイブのみを生成
#

set -euo pipefail

cd "$(dirname "$0")/.."

MODE="${1:-all}"
BUILD_DIR="build/release"
DIST_DIR="build/dist"

mkdir -p "$DIST_DIR"

echo "======================================================"
echo "  アーカイブ生成を開始します (CPack: モード '$MODE')"
echo "======================================================"

case "$MODE" in
  source)
    # ソースアーカイブのみ生成 (コンパイル不要・configureのみ)
    echo ""
    echo "--- [1/2] CMake を設定しています (ソースパッケージ用) ---"
    cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

    echo ""
    echo "--- [2/2] CPack でソースアーカイブ (.tar.gz) を生成しています ---"
    (cd "$BUILD_DIR" && cpack --config CPackSourceConfig.cmake)
    ;;

  bin)
    # バイナリアーカイブのみ生成
    echo ""
    echo "--- [1/3] CMake Release ビルドを設定しています ---"
    cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

    echo ""
    echo "--- [2/3] プロジェクトを並列コンパイルしています ---"
    cmake --build "$BUILD_DIR" --parallel

    echo ""
    echo "--- [3/3] CPack でバイナリアーカイブ (.tar.gz) を生成しています ---"
    (cd "$BUILD_DIR" && cpack -G TGZ)
    ;;

  all)
    # バイナリとソースの両方を生成
    echo ""
    echo "--- [1/4] CMake Release ビルドを設定しています ---"
    cmake -B "$BUILD_DIR" -S . -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

    echo ""
    echo "--- [2/4] プロジェクトを並列コンパイルしています ---"
    cmake --build "$BUILD_DIR" --parallel

    echo ""
    echo "--- [3/4] CPack でバイナリアーカイブ (.tar.gz) を生成しています ---"
    (cd "$BUILD_DIR" && cpack -G TGZ)

    echo ""
    echo "--- [4/4] CPack でソースアーカイブ (.tar.gz: Yocto向け) を生成しています ---"
    (cd "$BUILD_DIR" && cpack --config CPackSourceConfig.cmake)
    ;;

  *)
    echo "エラー: 不明なモード '$MODE' です。指定可能なモード: all, source, bin" >&2
    exit 1
    ;;
esac

# 生成されたアーカイブを dist/ ディレクトリに移動
echo ""
echo "--- アーカイブを '$DIST_DIR/' ディレクトリに集約しています ---"
find "$BUILD_DIR" -maxdepth 1 -name "*.tar.gz" -exec mv -v {} "$DIST_DIR/" \;

echo ""
echo "======================================================"
echo "  アーカイブの生成が完了しました！"
echo "  出力ディレクトリ: $(pwd)/$DIST_DIR"
echo "======================================================"
ls -lh "$DIST_DIR"

echo ""
echo "--- SHA-256 チェックサム (Yocto bb ファイルの SRC_URI[sha256sum] 用) ---"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DIST_DIR"/*.tar.gz || true
fi
