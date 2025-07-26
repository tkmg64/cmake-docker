#!/bin/bash
#
# build.sh - プロジェクトのビルド用スクリプト
#
# 使い方:
# 1. このファイルをプロジェクトのルートディレクトリに `build.sh` として保存します。
# 2. 実行権限を付与します: chmod +x build.sh
# 3. スクリプトを実行します: ./build.sh
#

# -e: コマンドが失敗した時点でスクリプトを終了する
# -u: 未定義の変数が使用された場合にエラーとする
# -o pipefail: パイプラインの途中でコマンドが失敗した場合に、その時点で失敗とする
set -euo pipefail

# スクリプトのあるディレクトリを基準にする
cd "$(dirname "$0")"

# ビルドディレクトリを定義
BUILD_DIR="build"

# ビルドディレクトリが存在しない場合は作成
if [ ! -d "$BUILD_DIR" ]; then
  echo "ビルドディレクトリ '$BUILD_DIR' を作成します..."
  mkdir "$BUILD_DIR"
fi

# ビルドディレクトリに移動
cd "$BUILD_DIR"

echo "--- CMakeを実行しています ---"
cmake ..

echo ""
echo "--- プロジェクトをビルドしています ---"
make

echo ""
echo "ビルドが完了しました。"
echo "実行可能ファイルは './build/app1/app1' と './build/app2/app2' にあります。"
