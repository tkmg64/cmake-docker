# アプリケーションのロジック部分をライブラリとして定義
add_library(app2_lib src/app2.cpp src/app2.h)

# Coverageビルドの場合、カバレッジ用のフラグをライブラリに直接追加
if (CMAKE_BUILD_TYPE STREQUAL "Coverage")
    target_compile_options(app2_lib PRIVATE --coverage)
    target_link_libraries(app2_lib PRIVATE gcov)
endif()

# main関数を含むソースから実行可能ファイルを作成
add_executable(app2 src/main2.cpp)

# 実行可能ファイルにライブラリをリンク
target_link_libraries(app2 PRIVATE app2_lib)

#
# テストの設定
#
# テスト用の実行可能ファイルを作成
add_executable(app2_test test/test2.cpp)

# テスト実行ファイルに、テスト対象のライブラリとGoogleTestをリンク
target_link_libraries(app2_test PRIVATE app2_lib gtest_main)

# GoogleTestのインクルード
include(GoogleTest)

# テストを自動で検出する
gtest_discover_tests(app2_test)
