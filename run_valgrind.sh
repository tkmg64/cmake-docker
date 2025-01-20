#!/bin/bash

# 実行ファイルのパスを設定
EXECUTABLE="./build/test/testSampleApp"

# 実行ファイルが存在しない場合はエラーメッセージを表示
if [ ! -f "$EXECUTABLE" ]; then
    echo "エラー: 実行ファイル $EXECUTABLE が見つかりません。"
    echo "ビルドを実行してください。"
    exit 1
fi

# valgrind用のディレクトリを作成
VALGRIND_DIR="./valgrind_output"
mkdir -p "$VALGRIND_DIR"

# valgrindのオプション設定
VALGRIND_OPTIONS="--tool=memcheck \
                  --leak-check=full \
                  --show-leak-kinds=all \
                  --track-origins=yes \
                  --verbose \
                  --trace-children=yes \
                  --track-fds=yes \
                  --error-exitcode=1 \
                  --suppressions=$VALGRIND_DIR/suppress.txt"

# suppress.txtが存在しない場合は空ファイルを作成
if [ ! -f "$VALGRIND_DIR/suppress.txt" ]; then
    touch "$VALGRIND_DIR/suppress.txt"
fi

# 現在の日時を取得してファイル名に使用
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
OUTPUT_FILE="$VALGRIND_DIR/valgrind_${TIMESTAMP}.txt"

# valgrindを実行
valgrind $VALGRIND_OPTIONS $EXECUTABLE 2>&1 | tee "$OUTPUT_FILE"

# 終了コードを保存
exit_code=${PIPESTATUS[0]}

echo "Valgrindの実行が完了しました。詳細は${OUTPUT_FILE}を確認してください。"
exit $exit_code
