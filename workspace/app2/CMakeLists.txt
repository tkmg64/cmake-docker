# アプリケーションのロジック部分をライブラリとして定義
add_library(app2_lib src/app2.cpp src/app2.h)
target_include_directories(app2_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(app2_lib PUBLIC project_warnings)

# main関数を含むソースから実行可能ファイルを作成
add_executable(app2 src/main2.cpp)
target_link_libraries(app2 PRIVATE app2_lib project_warnings)
install(TARGETS app2 DESTINATION ${CMAKE_INSTALL_BINDIR})

#
# テストの設定
#
add_executable(app2_test test/test2.cpp)
target_link_libraries(app2_test PRIVATE app2_lib GTest::gtest_main project_warnings)

# GoogleTestの自動検出
include(GoogleTest)
gtest_discover_tests(app2_test)
