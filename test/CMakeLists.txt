# テスト実行ファイルの名前を設定
set(TestBinary testSampleApp)

# ソースファイルの収集
# GLOBで指定ディレクトリの全ての.cppファイルを取得
file(GLOB MY_SRCS ${PROJECT_SOURCE_DIR}/src/*.cpp)
set(MY_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/src)

# main.cppを除外したソースファイルリストを作成
# テストでは独自のmain関数を使用するため
set(MY_SRCS_MINUS_MAIN ${MY_SRCS})
list(REMOVE_ITEM MY_SRCS_MINUS_MAIN ${PROJECT_SOURCE_DIR}/src/main.cpp)

# テストソースファイルの収集
file(GLOB MY_TEST_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
set(MY_TEST_INCLUDE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# テスト実行ファイルのビルド設定
add_executable(${TestBinary}
  ${MY_TEST_SRCS}         # テストソース
  ${MY_SRCS_MINUS_MAIN}   # テスト対象のソース（main.cppを除く）
)

# インクルードパスの設定
target_include_directories(${TestBinary} PUBLIC
  ${MY_INCLUDE_PATH}      # プロダクトコードのヘッダー
  ${MY_TEST_INCLUDE_PATH} # テストコードのヘッダー
)

# 必要なライブラリとのリンク
target_link_libraries(${TestBinary} 
  gtest_main             # GoogleTestのメイン関数を使用
  ${Boost_LIBRARIES}     # Boostライブラリ
)