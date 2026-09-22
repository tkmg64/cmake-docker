# C++ 開発環境 (Docker + Modern CMake)

コンテナ化されたモダンな C++ 開発環境テンプレートです。CMake、Ninja、ccache、GoogleTest、VS Code Dev Containers、および各種静的・動的解析ツールが統合されており、快適かつ高速に C++ プロジェクトを開発できます。

## 主な特徴・環境構成

* **コンテナ環境**: `ubuntu:24.04` (非rootの `ubuntu` ユーザーで実行、ファイル権限の競合を解消)
* **ビルドシステム**: `CMake` (3.25+) + `Ninja` (高速並列ビルド) + `ccache` (コンパイルキャッシュ)
* **テスト**: `GoogleTest` (v1.15.2, `FetchContent` 経由) + `CTest`
* **静的・動的解析 & カバレッジ**:
  * 静的解析: `cppcheck`, `clang-tidy`
  * メモリ解析: `valgrind`
  * コードカバレッジ: `lcov` 2.0 / `genhtml`
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

# 静的解析 (cppcheck) の実行
./test.sh static

# メモリリーク解析 (Valgrind) の実行
./test.sh memory

# コードカバレッジ計測と HTML レポート生成 (lcov / genhtml)
./test.sh coverage

# 上記すべてのチェックを一括実行
./test.sh all
```

各テストの実行ログは `workspace/test_logs/` に自動保存され、ホスト側からも直接閲覧できます。
- `test_logs/unit_test.log`: ユニットテスト結果
- `test_logs/static_check.log`: 静的解析結果 (cppcheck)
- `test_logs/memory_check.log`: メモリ解析結果 (Valgrind)
- `test_logs/coverage.log`: カバレッジ計測ログ

カバレッジ計測を実行すると、`coverage_report/index.html` にレポートが生成されます。ホストマシンのブラウザで開いて確認してください。

### クリーンアップ

ビルドディレクトリやレポートを削除します。

```bash
./clean.sh
```

### コンテナの停止

作業を終了する場合は、ホスト側でコンテナを停止します。

```bash
docker compose down
```

---

## ディレクトリ構成

```
.
├── .clang-format       # コードフォーマット設定 (Google / LLVM ベース)
├── .devcontainer/      # VS Code Dev Containers 設定
│   └── devcontainer.json
├── .vscode/            # VS Code ローカル設定
│   └── settings.json
├── Dockerfile          # 開発用コンテナイメージ定義
├── compose.yml         # Docker Compose 設定 (V2仕様)
├── workspace/          # 開発作業ディレクトリ
│   ├── CMakeLists.txt  # ルート CMake 設定 (C++17, ccache, 共通警告設定)
│   ├── CMakePresets.json # CMake プリセット設定 (Debug, Release, Coverage)
│   ├── build.sh        # Ninja 並列ビルドスクリプト
│   ├── test.sh         # テスト・解析統合スクリプト
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