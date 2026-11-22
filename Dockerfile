FROM debian:trixie-20261104-slim

ARG IMAGE_CONAN_VENV
ARG IMAGE_USER
ARG IMAGE_USER_ID
ARG IMAGE_USER_HOME

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  clang-format \
  cmake \
  file \
  g++-aarch64-linux-gnu \
  gdb \
  git \
  mingw-w64 \
  ninja-build \
  python3 \
  python3-pip \
  python3-venv \
  && rm -rf /var/lib/apt/lists/*

ENV PATH="${IMAGE_CONAN_VENV}/bin:${PATH}"
RUN python3 -m venv "${IMAGE_CONAN_VENV}" \
  && pip install --no-cache-dir "conan==2.*"

RUN useradd ${IMAGE_USER} \
  -u ${IMAGE_USER_ID} \
  -m \
  -d ${IMAGE_USER_HOME} \
  -s /bin/bash

USER ${IMAGE_USER}
