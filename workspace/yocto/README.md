# Yocto Project (BitBake) 組み込みガイド

本ディレクトリには、当 C++ プロジェクトを Yocto Project (Poky / BitBake) でクロスビルドして組み込み Linux イメージに含めるためのレシピおよび設定手順をまとめています。

---

## 1. ソースアーカイブの生成

Yocto のビルドでは、ホスト側でビルドしたバイナリではなく、ターゲットアーキテクチャ（ARM, AArch64, x86_64 等）向けにクロスコンパイルするための **ソースコードアーカイブ (`MultiAppProject-X.Y.Z-Source.tar.gz`)** を使用します。

コンテナ内（またはホスト環境）で以下のコマンドを実行します：

```bash
# Yocto向けソースアーカイブを生成 (コンパイル不要で高速)
./package.sh source

# または バイナリとソース両方を生成
./package.sh all
```

生成されたアーカイブは `workspace/dist/` に出力され、ターミナル上に **SHA-256 チェックサム** が表示されます。

```text
dist/
└── MultiAppProject-1.0.0-Source.tar.gz
```

---

## 2. Yocto レイヤーへの配置方法

Yocto のカスタムメタレイヤー（例: `meta-my-layer`）に本レシピを組み込みます。

### 構成例 (ローカルファイル方式)

```text
meta-my-layer/
└── recipes-apps/
    └── multiappproject/
        ├── multiappproject_1.0.0.bb
        └── files/
            └── MultiAppProject-1.0.0-Source.tar.gz
```

1. レシピディレクトリを作成：
   ```bash
   mkdir -p meta-my-layer/recipes-apps/multiappproject/files
   ```
2. 本ディレクトリの `multiappproject_1.0.0.bb` をコピー：
   ```bash
   cp workspace/yocto/multiappproject_1.0.0.bb meta-my-layer/recipes-apps/multiappproject/
   ```
3. 生成したソースアーカイブを `files/` にコピー：
   ```bash
   cp workspace/dist/MultiAppProject-1.0.0-Source.tar.gz meta-my-layer/recipes-apps/multiappproject/files/
   ```

---

## 3. レシピのポイント

### ① `inherit cmake`
Yocto 標準の CMake クラスを継承しています。クロスコンパイル用のツールチェーン設定 (`toolchain.cmake`) が自動注入され、`do_configure`, `do_compile`, `do_install` が自動的に実行されます。

### ② `-DBUILD_TESTING=OFF` (オフラインビルド対応)
Yocto のビルドタスクは通常、外部ネットワークへのアクセスが制限されています。
本プロジェクトでは `EXTRA_OECMAKE += "-DBUILD_TESTING=OFF"` を指定することで、GoogleTest の `FetchContent`（GitHubからのダウンロード）とテストバイナリのビルドを無効化し、オフライン環境でも確実にビルドできるようにしています。

### ③ インストール先とパッケージング
`app1` および `app2` は CMake の `install(TARGETS ... DESTINATION ${CMAKE_INSTALL_BINDIR})` により、ターゲットの `/usr/bin/app1`, `/usr/bin/app2` にインストールされます。

---

## 4. ビルドとイメージへの組み込み

### 単体ビルドテスト
BitBake で本レシピ単体をビルドします：

```bash
bitbake multiappproject
```

### OS イメージへの組み込み
作成した実行ファイルを Linux イメージに含めるには、`build/conf/local.conf` またはカスタムイメージレシピに以下を追加します：

```bitbake
IMAGE_INSTALL:append = " multiappproject"
```
