# cmake-docker
cmake + googletest + coverage + docker (ubuntu) 環境構築

## ビルド
```
docker build -t cpp-dev-env .
```

## 実行
```
docker run -it --rm -v $(pwd):/workspace cpp-dev-env
```

### 永続化する場合
```
docker run -it --name cpp-dev-env-container -v $(pwd):/workspace cpp-dev-env
```