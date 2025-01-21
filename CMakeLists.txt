# CMakeの最小バージョンを指定
cmake_minimum_required(VERSION 3.20)

# プロジェクト名と使用言語を設定
project(SampleApp LANGUAGES CXX)

# C++言語バージョンの設定
# C++17を使用し、これを必須要件とする
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # コンパイラ固有の拡張機能を無効化

# コンパイラフラグの設定
# --coverage: コードカバレッジ計測を有効化
set(CMAKE_CXX_FLAGS "-Wall --coverage")  # 全ての警告を表示
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG")  # リリースビルド: 最適化レベル2
set(CMAKE_CXX_FLAGS_DEBUG "-g3 -O0")  # デバッグビルド: デバッグ情報最大、最適化なし

# GoogleTestの設定
# FetchContentを使用して自動的にGoogleTestをダウンロード
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip)
FetchContent_MakeAvailable(googletest)

# Boostライブラリの設定
# システムにインストールされているBoostを検索
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

# ソースコードとテストのディレクトリを追加
add_subdirectory(src)  # ソースコードのビルド設定
add_subdirectory(test) # テストコードのビルド設定
