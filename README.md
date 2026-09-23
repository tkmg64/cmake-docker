# C++ 開発環境 (Docker + Modern CMake)

Docker コンテナ化された C++17 開発環境テンプレートです。CMake、Ninja、ccache、GoogleTest、静的・動的解析（cppcheck, clang-tidy, valgrind, ASan）が統合されており、ホスト環境を汚さずに高速にビルド・テストを実行できます。

---

## クイックスタート (ホストから直接実行)

コンテナをバックグラウンド起動 (`up -d`) した状態で、ホスト側のターミナルから `docker compose exec` でコマンドを直接実行します。コンテナのシェルに入り込むことなく、ホスト環境からすべての操作を行えます。

### 1. コンテナの起動
作業開始時にコンテナをバックグラウンドで起動します：
```bash
docker compose up -d
```

### 2. プロジェクトのビルド
```bash
# Debug ビルド (デフォルト)
docker compose exec cpp-dev ./scripts/build.sh Debug

# Release ビルド
docker compose exec cpp-dev ./scripts/build.sh Release
```
ビルドされた実行ファイルは `workspace/build/debug/app/app` に生成されます。

### 3. アプリケーションの実行
```bash
docker compose exec cpp-dev ./build/debug/app/app
```

### 4. テスト・静的解析の実行
```bash
# ユニットテスト (GoogleTest & GoogleMock)
docker compose exec cpp-dev ./scripts/test.sh unit

# 全品質チェック一括実行 (単体テスト・静的解析・Valgrind・ASan・カバレッジ)
docker compose exec cpp-dev ./scripts/test.sh all

# コードフォーマット (整形 / 検証)
docker compose exec cpp-dev ./scripts/format.sh
docker compose exec cpp-dev ./scripts/format.sh check
```
※ 各種ログやカバレッジレポートは `workspace/build/reports/` に出力されます。

### 5. 詳細設計書 (Doxygen)・パッケージの生成
```bash
# Doxygen 設計書 HTML 生成 (workspace/build/reports/docs/html/)
docker compose exec cpp-dev ./scripts/doc.sh

# 配布用パッケージ生成 (workspace/build/dist/)
docker compose exec cpp-dev ./scripts/package.sh
```

### 6. クリーンアップ & コンテナの停止
```bash
# 生成物 (workspace/build/) の全削除
docker compose exec cpp-dev ./scripts/clean.sh

# 作業終了時のコンテナ停止
docker compose down
```

> [!TIP]
> **VS Code Dev Containers を使う場合**:
> VS Code で本リポジトリを開き、「Dev Containers: Reopen in Container」を選択すると、エディタ内で `F5`（デバッグ起動）や `Ctrl+Shift+B`（ビルドタスク）、テスト Explorer がそのまま利用できます。

---

## プロジェクトのカスタマイズ方法

本テンプレートをベースに新しいプロジェクトを開始する際の手順です。

### 1. プロジェクト名・基本情報の変更
- **`workspace/CMakeLists.txt`**:
  - `project(MultiAppProject CXX)` をご自身のプロジェクト名に変更
  - CPack 設定（`CPACK_PACKAGE_NAME` 等）を自身のパッケージ情報に変更
- **`workspace/doxygen/Doxyfile`**:
  - `PROJECT_NAME` や `PROJECT_BRIEF` を変更
- **`workspace/doxygen/src/mainpage.dox`**:
  - 設計書のタイトルやドキュメント概要を自身の仕様に合わせて記述

### 2. アプリケーション・モジュール構成の変更
- **`workspace/app/` の置き換え**:
  - サンプルの `app/` を自身のアプリケーション名・ライブラリ名にリネームまたは編集
  - 公開ヘッダーは `include/<名前空間>/`、実装コードは `src/`、テストは `test/` に配置
- **`workspace/CMakeLists.txt` の修正**:
  - ディレクトリ名を変更した場合は `add_subdirectory(...)` を修正
- **`workspace/app/CMakeLists.txt` の修正**:
  - ライブラリ名や実行ファイル名、依存関係を設定

### 3. VS Code デバッグ設定の更新
- **`.vscode/launch.json`** & **`workspace/.vscode/launch.json`**:
  - `program` に指定されているバイナリパス（`${workspaceFolder}/workspace/build/debug/app/app`）を、リネーム後のバイナリ名に変更

### 4. 社内環境・プロキシ設定 (必要な場合のみ)
社内 LAN などのプロキシ環境下でビルドする場合は、`.env.example` をコピーして `.env` を作成し、プロキシ情報を記述します：
```bash
cp .env.example .env
# .env を編集して社内プロキシのアドレスを記入
```

---

## ディレクトリ構成

```text
.
├── .devcontainer/      # VS Code Dev Containers 設定
├── .vscode/            # VS Code ローカル設定 (launch.json, tasks.json)
├── Dockerfile          # 開発用コンテナイメージ定義
├── compose.yml         # Docker Compose 設定
├── workspace/          # 開発作業ディレクトリ
│   ├── app/            # アプリケーションソース・ヘッダー・テスト
│   ├── doxygen/        # Doxygen 設定 (Doxyfile) および設計書ソース (src/)
│   ├── scripts/        # 各種シェルスクリプト (build, clean, test, doc, format, package)
│   ├── yocto/          # Yocto BitBake レシピ
│   ├── CMakeLists.txt  # ルート CMake 設定
│   ├── CMakePresets.json
│   ├── .clang-format
│   ├── .clang-tidy
│   └── .gitignore
└── README.md
```