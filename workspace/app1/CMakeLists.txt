# アプリケーションのロジック部分をライブラリとして定義
add_library(app1_lib src/app1.cpp src/app1.h)

# Coverageビルドの場合、カバレッジ用のフラグをライブラリに直接追加
if (CMAKE_BUILD_TYPE STREQUAL "Coverage")
    target_compile_options(app1_lib PRIVATE --coverage)
    target_link_libraries(app1_lib PRIVATE gcov)
endif()

# main関数を含むソースから実行可能ファイルを作成
add_executable(app1 src/main1.cpp)

# 実行可能ファイルにライブラリをリンク
target_link_libraries(app1 PRIVATE app1_lib)

#
# テストの設定
#
# テスト用の実行可能ファイルを作成
add_executable(app1_test test/test1.cpp)

# テスト実行ファイルに、テスト対象のライブラリとGoogleTestをリンク
target_link_libraries(app1_test PRIVATE app1_lib gtest_main)

# GoogleTestのインクルード
include(GoogleTest)

# テストを自動で検出する
gtest_discover_tests(app1_test)
