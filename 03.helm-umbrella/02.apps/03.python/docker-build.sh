#!/bin/bash
NAME=sk199
IMAGE_NAME="my-app-python"
VERSION="1.0.0"
DOCKERFILE="Dockerfile"

# -f / --file 인자 파싱
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--file)
      DOCKERFILE="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Docker 이미지 빌드
docker buildx build \
  --tag ${NAME}-${IMAGE_NAME}:${VERSION} \
  --file ${DOCKERFILE} \
  --platform linux/amd64 \
  ${IS_CACHE} .
