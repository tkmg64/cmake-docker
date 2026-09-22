# C++ 開発環境 (Docker + Modern CMake)

コンテナ化されたモダンな C++ 開発環境テンプレートです。CMake、Ninja、ccache、GoogleTest、VS Code Dev Containers、および各種静的・動的解析ツールが統合されており、快適かつ高速に C++ プロジェクトを開発できます。

## 主な特徴・環境構成

* **コンテナ環境**: `ubuntu:24.04` (非rootの `ubuntu` ユーザーで実行、ファイル権限の競合を解消)
* **ビルドシステム**: `CMake` (3.25+) + `Ninja` (高速並列ビルド) + `ccache` (コンパイルキャッシュ)
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

## 使い方

### 方法 A: VS Code Dev Containers を使う場合 (推奨)

VS Code の拡張機能「Dev Containers」がインストールされている場合、プロジェクトを開いて以下の操作を行うだけで環境がセットアップされます。

1. VS Code でこのディレクトリを開く。
2. 左下の緑色のアイコン、またはコマンドパレット (`F1` / `Ctrl+Shift+P`) から **「Dev Containers: Reopen in Container」** を選択。
3. 自動でコンテナがビルドされ、C++ 拡張機能・CMake Tools・デバッガなどが設定された状態でコンテナ内に接続されます。
4. ステータスバーから CMake のプリセット (Debug, Release, Coverage など) を選択してワンクリックでビルド・デバッグが可能です。

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

# 上記すべてのチェックを一括実行 (unit, static, memory, asan, coverage)
./test.sh all
```

各テストの実行ログは `workspace/test_logs/` に自動保存され、ホスト側からも直接閲覧できます。
- `test_logs/unit_test.log`: ユニットテスト結果
- `test_logs/static_check.log`: cppcheck 静的解析結果
- `test_logs/clang_tidy.log`: clang-tidy 静的解析結果
- `test_logs/memory_check.log`: メモリ解析結果 (Valgrind)
- `test_logs/sanitizer.log`: サニタイザ解析結果 (ASan / UBSan)
- `test_logs/coverage.log`: カバレッジ計測ログ

カバレッジ計測を実行すると、`coverage_report/index.html` にレポートが生成されます。ホストマシンのブラウザで開いて確認してください。

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
│   └── settings.json
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
│   ├── doc.sh          # Doxygen ドキュメント生成スクリプト
│   ├── clean.sh        # クリーンアップスクリプト
│   ├── app1/           # サンプルアプリケーション 1
│   │   ├── CMakeLists.txt
│   │   ├── src/
│   │   └── test/
│   └── app2/           # サンプルアプリケーション 2
│       ├── CMakeLists.txt
│       ├── src/
│       └── test/
└── README.md           # 本ドキュメント
```