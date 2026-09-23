# アプリケーションのロジック部分をライブラリとして定義
add_library(app_lib
    src/math/add.cpp
    include/app/math/add.h
    include/app/device/device.h
)
target_include_directories(app_lib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)
target_link_libraries(app_lib PUBLIC project_warnings)

# main関数を含むソースから実行可能ファイルを作成
add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE app_lib project_warnings)
install(TARGETS app DESTINATION ${CMAKE_INSTALL_BINDIR})

#
# テストの設定 (BUILD_TESTING が有効な場合のみビルド)
#
if(BUILD_TESTING)
    add_executable(app_test test/test_math.cpp test/test_mock.cpp)
    target_link_libraries(app_test PRIVATE app_lib GTest::gtest_main GTest::gmock project_warnings)

    # GoogleTestの自動検出
    include(GoogleTest)
    gtest_discover_tests(app_test)
endif()
