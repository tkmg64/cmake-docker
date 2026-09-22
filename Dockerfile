FROM ubuntu:24.04

# タイムゾーンの設定による対話的プロンプトを防ぐ
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# ロケールの設定
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    ccache \
    clang-format \
    clang-tidy \
    git \
    lcov \
    g++ \
    gdb \
    locales \
    valgrind \
    cppcheck \
    libboost-all-dev \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# ubuntuユーザー (UID: 1000) にパスワードなしsudo権限を付与
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

# ccache用ディレクトリの作成と権限設定
RUN mkdir -p /var/cache/ccache && chown -R ubuntu:ubuntu /var/cache/ccache
ENV CCACHE_DIR=/var/cache/ccache

# 作業ディレクトリの作成と権限設定
RUN mkdir -p /workspace && chown ubuntu:ubuntu /workspace
WORKDIR /workspace

# デフォルトユーザーを非rootのubuntuに設定
USER ubuntu

# デフォルトのコマンド
CMD ["/bin/bash"]