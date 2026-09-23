SUMMARY = "MultiAppProject - C++17 Multi-App CMake Project"
DESCRIPTION = "High-reliability C++17 Multi-App Project built with Modern CMake and Ninja"
HOMEPAGE = "https://github.com/tkmg64/cmake-docker"
SECTION = "apps"

# ライセンス設定 (プロジェクトのライセンスに合わせて変更してください)
LICENSE = "CLOSED"
# 例: MITライセンスの場合
# LICENSE = "MIT"
# LIC_FILES_CHKSUM = "file://LICENSE;md5=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#
# ソースアーカイブ (SRC_URI) の指定
#
# 【パターン1: ローカルアーカイブを利用する場合 (推奨・オフライン開発)】
#   レシピと同じディレクトリ、または recipes-*/<recipe_name>/files/ ディレクトリに
#   package.sh で生成された 'MultiAppProject-1.0.0-Source.tar.gz' を配置します。
SRC_URI = "file://MultiAppProject-${PV}-Source.tar.gz"

# 【パターン2: リモートサーバーや GitHub Releases から取得する場合】
#   package.sh 実行時に表示される SHA-256 チェックサムをここに指定します。
# SRC_URI = "https://github.com/example/releases/download/v${PV}/MultiAppProject-${PV}-Source.tar.gz"
# SRC_URI[sha256sum] = "<package.sh で出力された SHA-256 ハッシュ値を記載>"

# アーカイブ解凍先のソースディレクトリ (CPackのソースパッケージ名に合わせる)
S = "${WORKDIR}/MultiAppProject-${PV}-Source"

# CMake ビルドシステムを継承 (do_configure, do_compile, do_install が自動定義されます)
inherit cmake

# Yocto 環境向け CMake オプション設定
# - BUILD_TESTING=OFF: GoogleTest (FetchContent) のダウンロードと単体テストビルドを無効化 (オフラインビルド対応)
EXTRA_OECMAKE += "-DBUILD_TESTING=OFF"

# パッケージに含めるファイル指定
# app は CMAKE_INSTALL_BINDIR (/usr/bin) にインストールされるため、
# 通常はデフォルト設定で ${PN} パッケージに含まれます。明示指定する場合は以下をアンコメントしてください。
# FILES:${PN} += "${bindir}/app"
