# C++ 開発環境 (Docker + Modern CMake)

コンテナ化されたモダンな C++ 開発環境テンプレートです。CMake、Ninja、ccache、GoogleTest、VS Code Dev Containers、および各種静的・動的解析ツールが統合されており、快適かつ高速に C++ プロジェクトを開発できます。

## 主な特徴・環境構成

* **コンテナ環境**: `ubuntu:24.04` (非rootの `ubuntu` ユーザーで実行、ファイル権限の競合を解消)
* **ビルドシステム**: `CMake` (3.25+) + `Ninja` (高速並列ビルド) + `ccache` (コンパイルキャッシュ)
* **ロギング**: `spdlog` (v1.15.1, Git サブモジュール管理、オフラインビルド対応)
* **テスト**: `GoogleTest` (v1.15.2, `FetchContent` 経由) + `CTest`
* **静的・動的解析 & カバレッジ & ドキュメント**:
  * 静的解析: `cppcheck`, `clang-tidy` (MISRA C++:2023 等を参考とした静的解析)
  * メモリ解析: `valgrind`
  * コードカバレッジ: `lcov` 2.0 / `genhtml`
  * ドキュメント自動生成: `doxygen` + `graphviz` (コールグラフ・クラス図生成)
* **開発支援 (DX)**:
  * **VS Code Dev Containers** 対応 (`.devcontainer/devcontainer.json`)
  * **CMake Presets** 対応 (`CMakePresets.json`)
  * **Clang-Format** 設定 (`.clang-format`)
  * 自動ビルド・テスト用シェルスクリプト

---

## 新規プロジェクトへの導入手順 (カスタマイズチェックリスト)

本テンプレートを別の Git リポジトリにコピーして新しいプロジェクトを開始する際は、以下のファイルをプロジェクト名や構成に合わせて変更してください。

### 1. プロジェクト名 & パッケージ情報の変更
- [ ] **`workspace/CMakeLists.txt`**:
  - `project(MultiAppProject CXX)` をご自身のプロジェクト名に変更（例: `project(MyAwesomeProject CXX)`）
  - CPack 設定（`CPACK_PACKAGE_NAME`, `CPACK_PACKAGE_VENDOR`, `CPACK_PACKAGE_CONTACT` など）をご自身の情報に更新
- [ ] **`workspace/Doxyfile`**:
  - `PROJECT_NAME = "MultiAppProject"` をご自身のプロジェクト名に変更
  - `PROJECT_BRIEF`（概要説明文）を更新
- [ ] **`workspace/docs_src/mainpage.dox`**:
  - タイトル（`@mainpage ...`）や、改訂履歴（作成者名・日付）、システムアーキテクチャの解説をご自身の仕様に合わせて更新

### 2. アプリケーション・モジュール構成の変更
- [ ] **サンプルモジュール (`workspace/app1`, `app2`) の置き換え**:
  - サンプルの `app1/`, `app2/` をご自身のアプリケーション名・ライブラリ名にリネームまたは新規作成
  - 本テンプレートの標準レイアウト（`include/<名前空間>/` に公開ヘッダー、`src/` に実装コード）を参考にコードを配置
  - `workspace/CMakeLists.txt` 内の `add_subdirectory(app1)` を自身のディレクトリ名に修正
  - 各サブディレクトリの `CMakeLists.txt` で、パッケージング対象とする実行ファイルに `install(TARGETS <バイナリ名> DESTINATION ${CMAKE_INSTALL_BINDIR})` を記述

### 3. VS Code デバッグ設定の更新
- [ ] **`.vscode/launch.json`**:
  - `program` に指定されているバイナリパス（例: `${workspaceFolder}/workspace/build/app1/app1`）を、リネーム後のバイナリ名に変更

### 4. 社内環境・プロキシ設定 (必要な場合のみ)
- [ ] 社内ネットワーク等のプロキシ環境下でビルドする場合は、`.env.example` をコピーして `.env` を作成し、プロキシ情報を記述

---

## 使い方

### 0. リポジトリのクローン (Git サブモジュール)

本プロジェクトはサードパーティライブラリ (`spdlog`) を Git サブモジュールとして管理しています。
クローン時は `--recursive` オプションを指定してサブモジュールごと取得してください：

```bash
git clone --recursive <リポジトリURL>
```

すでにクローン済みの場合は、以下のコマンドでサブモジュールを初期化・取得してください：

```bash
git submodule update --init --recursive
```

---

### 方法 A: VS Code Dev Containers を使う場合 (推奨)

VS Code の拡張機能「Dev Containers」がインストールされている場合、プロジェクトを開いて以下の操作を行うだけで環境がセットアップされます。

1. VS Code でこのディレクトリを開く。
2. 左下の緑色のアイコン、またはコマンドパレット (`F1` / `Ctrl+Shift+P`) から **「Dev Containers: Reopen in Container」** を選択。
3. 自動でコンテナがビルドされ、C++ 拡張機能・CMake Tools・デバッガなどが設定された状態でコンテナ内に接続されます。
4. ステータスバーから CMake のプリセット (Debug, Release, Coverage など) を選択してワンクリックでビルド・デバッグが可能です。

---

### 社内ネットワーク (プロキシ環境) での利用方法

本テンプレートは、**プロキシあり／なしの両環境に自動対応**しています。
プロキシが不要な一般環境では追加設定なしでそのまま利用できます。

社内 LAN などでプロキシを経由する必要がある場合は、以下のいずれかで設定できます：

1. **ホスト側の環境変数をそのまま利用する場合**:
   ホスト環境で `HTTP_PROXY`, `HTTPS_PROXY` が設定されていれば、Docker Compose が自動的にコンテナビルドおよび実行時に透過します。
2. **`.env` ファイルで明示する場合**:
   リポジトリルートにある `.env.example` を `.env` にコピーして設定します：
   ```bash
   cp .env.example .env
   # .env を編集して社内プロキシのアドレスを記入
   ```
   > **Note:** `.env` は機密情報保護のため `.gitignore` により自動的に Git 除外されます。

> **GitHub Actions CI でのプロキシについて:**
> GitHub 提供の標準クラウドランナー（`ubuntu-latest`）は直接インターネットに接続するため、**プロキシの設定は不要**です。本リポジトリの構成は、プロキシ環境変数が未指定の場合は自動で「プロキシなし」として動作するため、社内と GitHub Actions で同一のコードをそのまま利用できます。

---

### 方法 B: CLI (ターミナル) で使う場合

#### 1. コンテナの起動

Docker Compose (V2) を使ってコンテナをビルド・起動します。

```bash
docker compose up -d --build
```

#### 2. コンテナに入る

コンテナのシェルにアクセスします (作業ディレクトリは `/workspace`、実行ユーザーは `ubuntu` です)。

```bash
docker compose exec cpp-dev bash
```

以降のコマンドはコンテナ内の `/workspace` で実行します。

---

## 開発ワークフロー (コンテナ内での操作)

### プロジェクトのビルド

`build.sh` スクリプトを実行すると、Ninja を使った高速並列ビルドが行われます。

```bash
./build.sh          # デフォルト: Debug ビルド
./build.sh Release  # Release ビルド
```

ビルドされた実行ファイルは `./build/app1/app1` および `./build/app2/app2` に生成されます。

> **Tips (CMake Presets を直接使う場合):**
> ```bash
> cmake --preset debug
> cmake --build --preset debug
> ```

### アプリケーションの実行

```bash
./build/app1/app1
./build/app2/app2
```

### テストと各種解析の実行

`test.sh` スクリプトでテストや品質チェックを実行できます。

```bash
# ユニットテスト (CTest / GoogleTest) の実行
./test.sh unit   # または引数なし: ./test.sh

# 静的解析 (cppcheck + clang-tidy)
./test.sh static

# clang-tidy の単独実行
./test.sh tidy

# メモリリーク解析 (Valgrind) の実行
./test.sh memory

# サニタイザ (AddressSanitizer / UndefinedBehaviorSanitizer) の実行
./test.sh asan

# コードカバレッジ計測と HTML レポート生成 (lcov / genhtml)
./test.sh coverage

# コードフォーマットの適用 / 検証
./test.sh format        # または ./format.sh (一括整形)
./test.sh format-check  # または ./format.sh check (差分検証)

# 上記すべてのチェックを一括実行 (format-check, unit, static, memory, asan, coverage)
./test.sh all
```

各テストの実行ログは `workspace/test_logs/` に自動保存され、ホスト側からも直接閲覧できます。
- `test_logs/unit_test.log`: ユニットテスト結果 (GoogleTest + GoogleMock)
- `test_logs/static_check.log`: cppcheck 静的解析結果
- `test_logs/clang_tidy.log`: clang-tidy 静的解析結果
- `test_logs/memory_check.log`: メモリ解析結果 (Valgrind)
- `test_logs/sanitizer.log`: サニタイザ解析結果 (ASan / UBSan)
- `test_logs/coverage.log`: カバレッジ計測ログ

カバレッジ計測を実行すると、`coverage_report/index.html` にレポートが生成されます。ホストマシンのブラウザで開いて確認してください。

---

### VS Code でのワンクリックデバッグ (F5)

VS Code の「実行とデバッグ」パネル（`Ctrl+Shift+D`）または **`F5` キー** を押すだけで、自動で最新ビルドが行われ、ブレークポイントを打った行で一時停止してステップ実行・変数確認が可能です。

- **デバッグ構成一覧**:
  - `app1 (Debug)`: 算術演算アプリケーションのデバッグ
  - `app2 (Debug)`: 文字列処理アプリケーションのデバッグ
  - `app1_test (Debug)`: app1 単体テスト & モックテストのデバッグ
  - `app2_test (Debug)`: app2 単体テストのデバッグ
- **タスクメニュー (`Ctrl+Shift+B`)**:
  - `Build (Debug)` / `Build (Release)` / `Format Code` / `Run All Tests & Checks` / `Package (.tar.gz)` が即座に呼び出せます。

---

### VS Code GUI でのテスト実行 (Test Explorer)

VS Code の **「テスト」パネル（ビーカーアイコン）** およびエディタ上のインライン操作から、テストの実行とデバッグが可能です。

- **エディタ上からのインライン実行 (▶)**:
  テストコード（`test1.cpp`, `test_mock.cpp` 等）を開くと、各 `TEST()` マクロの左側に **再生ボタン「▶」** が表示されます。クリックするだけで特定のテストケース単体をピンポイントで実行できます。
- **デバッグ実行**:
  「▶」ボタンを右クリックして「テストのデバッグ」を選択すると、そのテストケース内で打ったブレークポイントで即座に一時停止します。
- **Test Explorer ツリー**:
  サイドバーの「テスト」アイコンをクリックすると、プロジェクト内のテスト一覧がツリー表示され、全テストの一括実行や結果（緑チェック・赤バツ）の確認ができます。

---

### Google Mock (gmock) によるモックテスト

本テンプレートには、依存関係を抽象化してテストする **Google Mock** のサンプル（`app1/src/device.h` および `app1/test/test_mock.cpp`）が含まれています。

- **インターフェース (`IDevice`)**: 通信やハードウェアアクセスを純粋仮想関数として定義。
- **モッククラス (`MockDevice`)**: `MOCK_METHOD` マクロを用いて仮想関数をオーバーライド。
- **呼び出し検証**: `EXPECT_CALL(mock, write(...)).Times(1).WillOnce(testing::Return(true))` のように、呼び出し回数・引数・戻り値をシミュレーション検証できます。

---

### 配布用アーカイブ (.tar.gz) の生成 & Yocto (BitBake) 対応 (CPack)

CMake 標準の **CPack** を利用して、実行用バイナリアーカイブおよび Yocto (BitBake) レシピに指定可能な **ソースコードアーカイブ** を自動生成できます。

```bash
# バイナリとソースの両アーカイブを生成 (デフォルト)
./package.sh all
# または短縮形
./package.sh

# Yocto (BitBake) 向けソースアーカイブのみを高速生成 (コンパイル不要)
./package.sh source

# 配布用バイナリアーカイブのみを生成
./package.sh bin

# または test.sh 経由: ./test.sh package
```

生成されたアーカイブは `workspace/dist/` に出力され、ターミナル上に **SHA-256 チェックサム** が表示されます。

```text
dist/
├── MultiAppProject-1.0.0-Linux.tar.gz    # 実行可能バイナリ配布パッケージ
└── MultiAppProject-1.0.0-Source.tar.gz   # Yocto (BitBake) レシピ用ソースアーカイブ
```

#### Yocto (BitBake) での利用
Yocto のクロスコンパイル環境（ARM/AArch64等）でビルドする際は、ソースアーカイブ `MultiAppProject-1.0.0-Source.tar.gz` をレシピの `SRC_URI` に指定します。

* サンプルレシピ: `workspace/yocto/multiappproject_1.0.0.bb`
* 詳細な組み込み手順: `workspace/yocto/README.md`

> [!TIP]
> CMake の `BUILD_TESTING=OFF` に対応しているため、Yocto のオフラインビルド環境でも GoogleTest (FetchContent) の外部ダウンロードを発生させずにクリーンにビルドできます。

#### バイナリアーカイブの展開と実行方法 (ホスト環境)
管理者権限（root）は不要です。任意のディレクトリで解凍するだけで即座に実行できます。

```bash
# アーカイブを解凍
tar -xzf MultiAppProject-1.0.0-Linux.tar.gz

# 実行
./MultiAppProject-1.0.0-Linux/bin/app1
./MultiAppProject-1.0.0-Linux/bin/app2
```

> [!NOTE]
> GitHub Actions CI でも自動的に `.tar.gz` パッケージ（バイナリおよびソース）が生成され、CI 実行結果の「Artifacts」からダウンロード可能です。

---

### Doxygen ソフトウェア詳細設計書の生成

Doxygen と Graphviz により、ソースコード内のコメントから詳細設計書（HTML）および関数のコールグラフ・インクルード依存関係図を自動生成します。

```bash
# 詳細設計書を生成
./doc.sh
# または test.sh 経由: ./test.sh doc
```

生成されたドキュメントは `workspace/docs/html/index.html` に出力されます。ホストマシンのブラウザで開いて確認してください。

---

## 安全なコーディング方針 (MISRA C++:2023 参考)

本テンプレートは、安全・高信頼性システム向けのガイドライン **MISRA C++:2023** や **AUTOSAR / CERT** 等の考え方をベース・参考として取り入れています。

> **Note:** 本環境はオープンソースツール（Clang-Tidy / GCC 警告）を活用して安全なコーディング方針を支援するものであり、商用の公式 MISRA 認証ツールによる適合証明ではありません。

1. **コンパイラ警告による不具合防止 (`CMakeLists.txt`)**:
   - 暗黙の型変換・符号縮小の禁止 (`-Wconversion`, `-Wsign-conversion`, `-Wfloat-conversion`)
   - Cスタイルキャストの禁止 (`-Wold-style-cast`)
   - 変数のシャドウイング防止 (`-Wshadow`)
   - 未初期化変数、null逆参照、switch文フォールスルーの検出
2. **Clang-Tidy による静的解析 (`.clang-tidy`)**:
   - MISRA C++:2023 の基盤となった **AUTOSAR C++14**, **CERT C++**, **HICPP**, **C++ Core Guidelines** のルールセットを適用。
3. **コーディング規約の適用例**:
   - 基本型の曖昧なサイズ依存を避ける `<cstdint>` 固定幅整数型 (`std::int32_t` など) の使用
   - 例外を投げない関数の `noexcept` 明示
   - 関数の戻り値チェックを促す `[[nodiscard]]` 属性
   - 安全・軽量な参照渡し (`std::string_view`, const 参照)

### クリーンアップ

ビルドディレクトリ、テストログ、カバレッジ、および生成ドキュメントを削除します。

```bash
./clean.sh
```

### コンテナの停止

作業を終了する場合は、ホスト側でコンテナを停止します。

```bash
docker compose down
```

---

## CI/CD パイプライン (GitHub Actions)

本リポジトリには、プッシュおよびプルリクエスト時に自動実行される GitHub Actions ワークフロー (`.github/workflows/ci.yml`) が設定されています。

- **実行内容**:
  1. Docker 開発環境イメージのビルド (`docker compose build`)
  2. 全品質チェックの実行 (`./test.sh all`: ユニットテスト、静的解析、Valgrind、ASan/UBSan、カバレッジ)
  3. Doxygen ソフトウェア詳細設計書の自動生成 (`./doc.sh`)
  4. テストログ、カバレッジレポート、および Doxygen ドキュメントのアーティファクト保存 (GitHub 画面からダウンロード可能)

ローカル環境と同一のコンテナ定義で CI が動作するため、「ローカルでは動いたが CI で失敗する」環境依存トラブルを防止します。

---

## 外部ライブラリの管理 (Git サブモジュール & オフラインビルド対応)

本テンプレートでは、外部ライブラリ（サードパーティ製 C++ ライブラリ）の組み込み方式として **Git サブモジュール + `add_subdirectory`** を採用しています（標準例: `spdlog`）。

### なぜ Git サブモジュール方式なのか？
1. **完全なオフラインビルド対応**:
   - `FetchContent` などの自動ダウンロード方式とは異なり、開発環境にコード一式が保持されるため、外部ネットワークから遮断されたオフライン環境（社内閉域網、エアギャップ環境、Yocto/BitBake ビルド等）でも通信エラーなくビルドできます。
2. **CPack ソースパッケージへの自動同梱**:
   - `./package.sh source` で生成されるソースアーカイブ (`.tar.gz`) に `workspace/third_party/` 配下のソースコードが丸ごと含まれます。アーカイブを展開するだけで、外部通信なしにターゲット環境でクロスコンパイルが可能です。
3. **再現性とバージョン固定**:
   - Git のコミットハッシュ単位で正確にバージョンが固定されるため、依存ライブラリの意図しない破壊的変更を防ぎます。

### 新しい外部ライブラリを追加する手順
ホスト環境（リポジトリルート）で以下を実行します：

```bash
# 1. workspace/third_party/<ライブラリ名> にサブモジュールを追加
git submodule add <GitリポジトリURL> workspace/third_party/<ライブラリ名>

# 2. 必要に応じて特定タグ/コミットにチェックアウト
cd workspace/third_party/<ライブラリ名>
git checkout <タグ名>
cd ../../

# 3. workspace/CMakeLists.txt に add_subdirectory を追加
# 4. アプリケーションの CMakeLists.txt で target_link_libraries に追加
```

---

## ディレクトリ構成

```
.
├── .github/             # GitHub 連携設定
│   └── workflows/
│       └── ci.yml      # GitHub Actions CI/CD パイプライン定義
├── .clang-format       # コードフォーマット設定 (Google / LLVM ベース)
├── .clang-tidy         # 静的解析設定 (MISRA C++:2023 / AUTOSAR / CERT 参考)
├── .devcontainer/      # VS Code Dev Containers 設定
│   └── devcontainer.json
├── .vscode/            # VS Code ローカル設定
│   ├── settings.json
│   ├── launch.json     # デバッグ起動設定 (F5 / GDB)
│   ├── tasks.json      # ビルド・テストタスク定義
│   └── extensions.json # 推奨拡張機能定義 (C++ TestMate等)
├── .env.example        # 社内プロキシ設定サンプル (必要時のみ .env にコピー)
├── Dockerfile          # 開発用コンテナイメージ定義
├── compose.yml         # Docker Compose 設定 (V2仕様)
├── workspace/          # 開発作業ディレクトリ
│   ├── CMakeLists.txt  # ルート CMake 設定 (C++17, ccache, Doxygen連携)
│   ├── CMakePresets.json # CMake プリセット設定 (Debug, Release, Coverage)
│   ├── Doxyfile        # Doxygen ドキュメント生成設定
│   ├── docs_src/       # 設計書ドキュメント定義 (Doxygen .dox 等)
│   │   └── mainpage.dox # 詳細設計書メインページ定義
│   ├── build.sh        # Ninja 並列ビルドスクリプト
│   ├── test.sh         # テスト・解析統合スクリプト
│   ├── format.sh       # コードフォーマット一括適用・検証スクリプト
│   ├── doc.sh          # Doxygen ドキュメント生成スクリプト
│   ├── package.sh      # 配布用アーカイブ (.tar.gz) 生成スクリプト
│   ├── clean.sh        # クリーンアップスクリプト
│   ├── app1/           # サンプルアプリケーション 1 (ドメイン分割構成のお手本)
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── app1/
│   │   │       ├── math/add.h        # 算術演算公開ヘッダー
│   │   │       └── device/device.h   # 抽象通信公開ヘッダー
│   │   ├── src/
│   │   │   ├── math/add.cpp          # 算術演算ロジック実装
│   │   │   └── main.cpp              # main 関数
│   │   └── test/
│   │       ├── test_math.cpp         # 算術演算単体テスト
│   │       └── test_mock.cpp         # Google Mock モックテスト
│   └── app2/           # サンプルアプリケーション 2 (シンプル構成のお手本)
│       ├── CMakeLists.txt
│       ├── include/
│       │   └── app2/
│       │       └── app2.h            # 文字列処理公開ヘッダー
│       ├── src/
│       │   ├── app2.cpp              # 文字列処理ロジック実装
│       │   └── main.cpp              # main 関数
│       └── test/
│           └── test2.cpp             # 文字列処理単体テスト
│   └── third_party/    # サードパーティ外部ライブラリ (Git サブモジュール)
│       └── spdlog/     # spdlog 高速ロギングライブラリ (オフラインビルド対応)
└── README.md           # 本ドキュメント
```