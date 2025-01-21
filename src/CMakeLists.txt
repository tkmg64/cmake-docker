# 実行ファイルとライブラリの名前を設定
set(BinaryName SampleApp)
set(LibraryName ${BinaryName}Lib)

# ソースファイルの自動収集
file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

# 共有ライブラリのビルド設定
# SHARED指定で動的ライブラリ(.so/.dll)を生成
add_library(${LibraryName} SHARED ${SOURCES})
# インクルードディレクトリを指定（PUBLICで依存先にも伝播）
target_include_directories(${LibraryName} PUBLIC include)

# 実行ファイルのビルド設定
add_executable(${BinaryName} ${SOURCES})
# インクルードディレクトリを指定
target_include_directories(${BinaryName} PUBLIC include)
# 実行ファイルと共有ライブラリをリンク
target_link_libraries(${BinaryName} ${LibraryName})