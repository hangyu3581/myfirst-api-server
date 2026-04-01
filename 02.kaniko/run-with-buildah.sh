#!/bin/bash

#set -xuo pipefail

IMG_TAG=python-buildah

# 1) CPU 플랫폼 (기본 amd64)
if [ "${1:-}" = "arm64" ]; then
  CPU_PLATFORM=arm64
  IMG_TAG=${CPU_PLATFORM}-${IMG_TAG}
else
  CPU_PLATFORM=amd64
fi

ENV_PROPERTIES=../env.properties

# 2) env.properties 로드
if [ -f "$ENV_PROPERTIES" ]; then
  while IFS='=' read -r key value; do
    case "$key" in
      ''|\#*) continue ;;
    esac
    value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//" -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    export "$key=$value"
  done < "$ENV_PROPERTIES"
else
  echo "env.properties 파일을 찾을 수 없습니다."
  exit 1
fi

# 3) 현재 디렉터리
CURRENT_DIR=$(pwd)

# 4) 푸시될 이미지 참조 (Kaniko와 구분 위해 suffix 변경)
IMAGE_REF="${DOCKER_REGISTRY}/${USER_NAME}-${IMAGE_NAME}:${VERSION}.${IMG_TAG}"

# 5) Buildah 컨테이너로 빌드/푸시
#    - vfs + chroot: 컨테이너/쿠버네티스 환경에서 권한 문제 회피
#    - $CPU_PLATFORM 전달: buildah bud --platform 지원 시 사용, 미지원 시 --arch로 대체
#  quay.io/buildah/stable:latest \
docker run --rm \
  -e REG_HOST="$(echo "$DOCKER_REGISTRY" | cut -d/ -f1)" \
  -e REG_PATH="$(echo "$DOCKER_REGISTRY" | cut -d/ -f2-)" \
  -e REG_USER="$DOCKER_REGISTRY_USER" \
  -e REG_PASS="$DOCKER_REGISTRY_PASSWORD" \
  -e CPU_PLATFORM="$CPU_PLATFORM" \
  -e IMAGE_REF="$IMAGE_REF" \
  -v "${CURRENT_DIR}:/workspace" \
  -w /workspace \
  --privileged \
  amdp-registry.skala-ai.com/library/stable:latest \
  bash -c '
    set -eux

    #buildah bud --isolation=chroot --storage-driver=vfs --platform "linux/$CPU_PLATFORM" -t "$IMAGE_REF" .
    buildah bud --storage-driver=vfs --platform "linux/${CPU_PLATFORM}" -t "$IMAGE_REF" .

    echo "[info] Login to registry: $REG_HOST"
    buildah login -u "$REG_USER" -p "$REG_PASS" "$REG_HOST"
    buildah push --storage-driver=vfs "$IMAGE_REF"

    '
