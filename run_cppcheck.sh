#!/bin/bash

# 出力ディレクトリの作成
OUTPUT_DIR="analysis_results/cppcheck"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="cppcheck_report_${TIMESTAMP}.xml"
HTML_DIR="html_report_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

# 除外するディレクトリの設定
EXCLUDE_DIRS="--suppress=missingInclude \
              --suppress=unmatchedSuppression \
              -i googletest \
              -i build \
              -i external \
              -i third_party \
              -i deps"

# cppcheckの実行オプション
CPPCHECK_OPTIONS="--enable=all \
                  --inconclusive \
                  --force \
                  --inline-suppr \
                  --xml \
                  --xml-version=2"

# ソースコードのチェック実行
# XMLファイルに出力
cppcheck $CPPCHECK_OPTIONS $EXCLUDE_DIRS . 2>"$OUTPUT_DIR/$REPORT_FILE"

# HTMLレポートの生成
cppcheck-htmlreport --file="$OUTPUT_DIR/$REPORT_FILE" \
                    --report-dir="$OUTPUT_DIR/$HTML_DIR" \
                    --source-dir=.

echo "解析が完了しました。"
echo "結果は $OUTPUT_DIR ディレクトリに保存されています。"
echo "HTML形式のレポートは $OUTPUT_DIR/$HTML_DIR/index.html で確認できます。"
