# CMakeの最低バージョンを指定
cmake_minimum_required(VERSION 3.14)

# プロジェクト名を設定
project(MultiAppProject CXX)

# C++の標準を17に設定
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# カバレッジ計測用のビルド設定 (GCC/Clang用)
# CMAKE_BUILD_TYPE=Coverage でビルドした際に有効になるコンパイラフラグ
if(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS_COVERAGE "-g -O0 --coverage" CACHE STRING "Flags used by the C++ compiler for coverage builds.")
    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE "--coverage" CACHE STRING "Flags used for linking binaries for coverage builds.")
    set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE "--coverage" CACHE STRING "Flags used for linking shared libraries for coverage builds.")
endif()

#
# GoogleTestのセットアップ
#
# FetchContentモジュールをインクルード
include(FetchContent)

# GoogleTestをダウンロードするための情報を宣言
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG    release-1.12.1
)

# googletestのビルド時にテストを無効にする (推奨)
set(gtest_build_tests OFF CACHE BOOL "" FORCE)
set(gmock_build_tests OFF CACHE BOOL "" FORCE)

# googletestをプロジェクトで利用可能にする
FetchContent_MakeAvailable(googletest)

# CTestを有効にする
enable_testing()

#
# サブプロジェクトを追加
#
# 各アプリケーションのディレクトリをサブプロジェクトとして追加
add_subdirectory(app1)
add_subdirectory(app2)
