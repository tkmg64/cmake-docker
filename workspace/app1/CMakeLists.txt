# アプリケーションのロジック部分をライブラリとして定義
add_library(app1_lib
    src/math/add.cpp
    include/app1/math/add.h
    include/app1/device/device.h
)
target_include_directories(app1_lib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_link_libraries(app1_lib PUBLIC project_warnings spdlog::spdlog)

# main関数を含むソースから実行可能ファイルを作成
add_executable(app1 src/main.cpp)
target_link_libraries(app1 PRIVATE app1_lib project_warnings)
install(TARGETS app1 DESTINATION ${CMAKE_INSTALL_BINDIR})

#
# テストの設定 (BUILD_TESTING が有効な場合のみビルド)
#
if(BUILD_TESTING)
    add_executable(app1_test test/test_math.cpp test/test_mock.cpp)
    target_link_libraries(app1_test PRIVATE app1_lib GTest::gtest_main GTest::gmock project_warnings)

    # GoogleTestの自動検出
    include(GoogleTest)
    gtest_discover_tests(app1_test)
endif()
