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

# サニタイザ (AddressSanitizer / UndefinedBehaviorSanitizer) のビルド設定
option(ENABLE_SANITIZER "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)
if(ENABLE_SANITIZER)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(STATUS "Sanitizers enabled (AddressSanitizer, UndefinedBehaviorSanitizer)")
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer -g)
        add_link_options(-fsanitize=address,undefined)
    endif()
endif()

# オプション: ビルド時のclang-tidy自動実行
option(ENABLE_CLANG_TIDY "Enable clang-tidy static analysis during build" OFF)

# プロジェクト共通の警告フラグ設定 (MISRA C++:2023 などの安全ガイドラインを参考)
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
# テストのセットアップ (BUILD_TESTING が ON の場合のみ GoogleTest を取得)
# Yocto 等のクロスコンパイル環境では -DBUILD_TESTING=OFF で外部通信とテストビルドを無効化可能
#
include(CTest)
if(BUILD_TESTING)
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
endif()

# 標準インストールディレクトリ変数を定義 (bin, lib, include など)
include(GNUInstallDirs)

# サブプロジェクト (app) に適用する clang-tidy の有効化 (サードパーティへの不要なチェックを回避)
if(ENABLE_CLANG_TIDY)
    find_program(CLANG_TIDY_PROGRAM clang-tidy)
    if(CLANG_TIDY_PROGRAM)
        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_PROGRAM}")
        message(STATUS "clang-tidy enabled for project targets: ${CLANG_TIDY_PROGRAM}")
    endif()
endif()

# サブプロジェクトを追加
add_subdirectory(app)

#
# Doxygen ドキュメント生成ターゲット (doc)
#
find_package(Doxygen)
if(DOXYGEN_FOUND)
    add_custom_target(doc
        COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/doxygen/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen..."
        VERBATIM
    )
endif()

#
# パッケージング設定 (CPack)
#
set(CPACK_PACKAGE_NAME "MultiAppProject")
set(CPACK_PACKAGE_VENDOR "Development Team")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "High-reliability C++17 Multi-App Project")
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 0)
set(CPACK_PACKAGE_VERSION_PATCH 0)
set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
set(CPACK_PACKAGE_CONTACT "dev@example.com")

# バイナリアーカイブ設定 (TGZ: .tar.gz)
set(CPACK_GENERATOR "TGZ")

# ソースアーカイブ設定 (Yocto / BitBake 等のクロスビルド向け)
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-Source")
set(CPACK_SOURCE_IGNORE_FILES
    "/build/"
    "/\.git/"
    "/\.git$"
    "/\.cache/"
    "/\.vscode/"
    ".*~$"
    "\\\\.swp$"
    "\\\\.DS_Store$"
)

include(CPack)

