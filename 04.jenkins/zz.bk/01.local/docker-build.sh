#!/bin/bash
IMAGE_NAME="custom-jenkins"
VERSION="1.1"

# 첫 번째 인자로 CPU 플랫폼 설정
if [ "$1" = "arm64" ]; then
  CPU_PLATFORM=arm64
else
  CPU_PLATFORM=amd64
fi

#IS_CACHE="--no-cache"

echo "Building for platform: ${CPU_PLATFORM}"

# Docker 이미지 빌드
docker build \
  --tag ${IMAGE_NAME}-${CPU_PLATFORM}:${VERSION} \
  --file Dockerfile \
  --platform linux/${CPU_PLATFORM} \
  ${IS_CACHE} .
