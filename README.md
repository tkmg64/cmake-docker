cmake-dockercmake + googletest + coverage + docker (ubuntu) 環境構築

# 使い方 (Docker Compose)
1. イメージのビルド `docker-compose build`
2. コンテナの起動 `docker-compose up -d`
3. コンテナ内での作業コンテナに入るには、以下のコマンドを実行します。
`docker-compose exec cpp-dev bash`
コンテナ内に入ったら、/workspaceディレクトリで作業を行います。
4. コンテナの停止 `docker-compose down`

# プロジェクトのビルド

## buildに移動
1. buildディレクトリを作成して移動
2. mkdir -p build && cd build

## cmakeを実行
cmake ..

## ビルド
make

## テストの実行
buildディレクトリにいることを確認
./test/testSampleApp


