FROM ubuntu:24.04

# タイムゾーンの設定による対話的プロンプトを防ぐ
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# ロケールの設定
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    lcov \
    libgtest-dev \
    g++ \
    gdb \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# GoogleTestのビルドとインストール
RUN cd /usr/src/gtest && \
    cmake CMakeLists.txt && \
    make && \
    cp lib/*.a /usr/lib

# 作業ディレクトリの設定
WORKDIR /workspace

# デフォルトのコマンド
CMD ["/bin/bash"] 