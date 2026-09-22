cmake_minimum_required(VERSION 3.25)

project(MultiAppProject CXX)

# C++の標準規格 (C++17)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# compile_commands.jsonの生成 (clangd / clang-tidy用)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ccacheがインストールされていれば自動で利用
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    message(STATUS "ccache enabled: ${CCACHE_PROGRAM}")
endif()

# カバレッジ計測用のビルド設定 (GCC/Clang用)
if(CMAKE_BUILD_TYPE STREQUAL "Coverage")
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(STATUS "Coverage build enabled (--coverage)")
        add_compile_options(--coverage -O0 -g)
        add_link_options(--coverage)
    endif()
endif()

# オプション: ビルド時のclang-tidy自動実行
option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis during build" OFF)
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_PROGRAM clang-tidy)
    if(CLANG_TIDY_PROGRAM)
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_PROGRAM}")
        message(STATUS "clang-tidy enabled: ${CLANG_TIDY_PROGRAM}")
    endif()
endif()

# プロジェクト共通の警告フラグ設定 (MISRA C++:2023 準拠強化)
add_library(project_warnings INTERFACE)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(project_warnings INTERFACE
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Wconversion
        -Wsign-conversion
        -Wfloat-conversion
        -Wuninitialized
        -Wnull-dereference
        -Wimplicit-fallthrough
    )
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(project_warnings INTERFACE
            -Wduplicated-cond
            -Wduplicated-branches
            -Wlogical-op
        )
    endif()
endif()

#
# GoogleTestのセットアップ (FetchContent)
#
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.15.2
)
# サードパーティのテストやインストール処理を無効化
set(gtest_build_tests OFF CACHE BOOL "" FORCE)
set(gmock_build_tests OFF CACHE BOOL "" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(googletest)

# CTestを有効化
enable_testing()

# サブプロジェクトを追加
add_subdirectory(app1)
add_subdirectory(app2)
