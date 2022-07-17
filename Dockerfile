FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt upgrade -y -q && apt install -y -q \
    build-essential \
    bzip2 \
    curl \
    file \
    g++ \
    gcc \
    git \
    make \
    sudo \
    unzip \
    xz-utils && \
    cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws*

RUN useradd -m -s /bin/bash build && \
    usermod -aG sudo build &&  \
    mkdir -p /home/build/
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN curl -sL https://github.com/bazelbuild/bazelisk/releases/download/v1.12.0/bazelisk-linux-amd64 -o /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

USER build

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN brew install --force-bottle --only-dependencies llvm
RUN brew install --force-bottle --force --verbose llvm

WORKDIR /home/build