FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt upgrade -y -q && apt install -y -q \
    build-essential \
    curl \
    git \
    lld \
    lldb \
    lsb-release \
    make \
    software-properties-common \
    wget \
    xz-utils \
    zlib1g-dev

RUN curl -o install-clang.sh -sL https://apt.llvm.org/llvm.sh && \
    chmod +x install-clang.sh && \
    ./install-clang.sh 18 all && \
    rm install-clang.sh
ENV CC=/usr/bin/clang-18

RUN curl -sL https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64 -o /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

# Bazel doesn't let us run as root.
RUN useradd -m -s /bin/bash build && \
    mkdir -p /home/build/
USER build

WORKDIR /home/build
COPY build/ .
