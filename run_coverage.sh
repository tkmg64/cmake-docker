#!/bin/bash

# 既存の.gcdaファイルをクリア
find . -name "*.gcda" -delete

# テストを実行してカバレッジデータを生成
./build/test/testSampleApp

# コピー元ディレクトリのパス
source_dir="build/test"

# コピー先ディレクトリのパス
destination_dir="analysis_results/coverage"

# ディレクトリを作成
mkdir -p "$destination_dir"

# *.gcda ファイルを検索してコピー
find "$source_dir" -name "*.gcda" -exec cp --parents {} "$destination_dir" \;
find "$source_dir" -name "*.gcno" -exec cp --parents {} "$destination_dir" \;

# make coverage data 
lcov --base-directory . --directory "$destination_dir" -c -o "$destination_dir"/coverage.info --ignore-errors mismatch --rc geninfo_unexecuted_blocks=1

# remove unnecessary file paths
lcov -r "$destination_dir"/coverage.info "*/googletest/*" "*/test/*" "*/c++/*" -o "$destination_dir"/coverageFiltered.info --ignore-errors unused,empty

# make html report
genhtml -o "$destination_dir"/lcovHtml --num-spaces 4 -s --legend "$destination_dir"/coverageFiltered.info