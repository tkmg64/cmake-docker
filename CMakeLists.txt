cmake_minimum_required(VERSION 3.20)

project(SampleApp LANGUAGES CXX)

# プロジェクトの設定
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# コンパイラフラグの設定
set(CMAKE_CXX_FLAGS "-Wall --coverage")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "-g3 -O0")

# テスト関連の設定
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip)
FetchContent_MakeAvailable(googletest)

# Boostライブラリの設定を追加
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

# サブディレクトリの追加
add_subdirectory(src)
add_subdirectory(test)
