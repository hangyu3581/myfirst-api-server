#!/bin/bash
set -euo pipefail

NAME="skala"
IMAGE_NAME="new-jenkins"
VERSION="1.0"

CPU_PLATFORM="amd64"
IS_CACHE="--no-cache"

DOCKER_REGISTRY="amdp-registry.skala-ai.com/library"
DOCKER_REGISTRY_USER="robot\$admin"
DOCKER_REGISTRY_PASSWORD="vpbFrswYsMuc2w6CH71ClTfsXLFNSn8f"

FULL_IMAGE="${DOCKER_REGISTRY}/${NAME}-${IMAGE_NAME}:${VERSION}"

echo "==> Building image: ${FULL_IMAGE}"
docker build \
  --tag "${FULL_IMAGE}" \
  --file Dockerfile \
  --platform "linux/${CPU_PLATFORM}" \
  ${IS_CACHE:-} .

echo "==> Logging in to registry: ${DOCKER_REGISTRY}"
echo "${DOCKER_REGISTRY_PASSWORD}" | docker login "${DOCKER_REGISTRY}" \
  -u "${DOCKER_REGISTRY_USER}" --password-stdin \
  || { echo "Docker 로그인 실패"; exit 1; }

echo "==> Pushing image: ${FULL_IMAGE}"
docker push "${FULL_IMAGE}"

echo "==> Done: ${FULL_IMAGE}"
