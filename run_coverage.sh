#!/bin/bash

# 既存の.gcdaファイルをクリア
find . -name "*.gcda" -delete

# テストを実行してカバレッジデータを生成
./build/test/testSampleApp

# 現在の時刻を取得（YYYYMMDD_HHMMSS形式）
timestamp=$(date '+%Y%m%d_%H%M%S')

# コピー元ディレクトリのパス
source_dir="build/test"

# コピー先ディレクトリのパス
base_dir="analysis_results/coverage"
destination_dir="${base_dir}/${timestamp}"

# ディレクトリを作成
mkdir -p "$destination_dir"

# *.gcda ファイルを検索してコピー
find "$source_dir" -name "*.gcda" -exec cp --parents {} "$destination_dir" \;
find "$source_dir" -name "*.gcno" -exec cp --parents {} "$destination_dir" \;

# make coverage data 
lcov --base-directory . --directory "$destination_dir" -c -o "$destination_dir"/coverage.info --ignore-errors mismatch --rc geninfo_unexecuted_blocks=1

# remove unnecessary file paths
lcov -r "$destination_dir"/coverage.info \
    "*/googletest/*" \
    "*/test/*" \
    "*/c++/*" \
    "*/boost/*" \
    -o "$destination_dir"/coverageFiltered.info \
    --ignore-errors unused,empty

# make html report
genhtml -o "$destination_dir"/lcovHtml --num-spaces 4 -s --legend "$destination_dir"/coverageFiltered.info