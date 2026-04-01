#!/bin/bash
#set -xuo pipefail

# 첫 번째 인자로 CPU 플랫폼 설정 (기본값: amd64)
if [ "${1:-}" = "arm64" ]; then
  CPU_PLATFORM=arm64
else
  CPU_PLATFORM=amd64
fi

ENV_PROPERTIES=./init-env.properties

# env.properties 파일에서 변수 읽어오기
if [ -f $ENV_PROPERTIES ]; then
    # env.properties 파일의 각 라인을 읽어 환경 변수로 설정
    while IFS='=' read -r key value
    do
        # 주석 라인 무시
        case "$key" in
            ''|\#*) continue ;;
        esac
        # 따옴표 제거 및 공백 제거
        value=$(echo $value | sed -e 's/^"//' -e 's/"$//' -e 's/^'\''//' -e 's/'\''$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        # 환경 변수로 설정
        export "$key=$value"
    done < $ENV_PROPERTIES
else
    echo "env.properties 파일을 찾을 수 없습니다."
    exit 1
fi

# Git 인증 확인
curl -s -u "$GIT_USERNAME:$GIT_PASSWORD" https://api.github.com/user | grep -q '"login"' || { echo "Git 인증 실패"; exit 1; }
curl -s -u "$GIT_USERNAME:$GIT_PASSWORD" https://api.github.com/user

# Docker 레지스트리 인증 확인
echo "$DOCKER_REGISTRY_PASSWORD" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_REGISTRY_USER" --password-stdin > /dev/null 2>&1 || { echo "Docker 레지스트리 인증 실패"; exit 1; }
echo "$DOCKER_REGISTRY_PASSWORD" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_REGISTRY_USER" --password-stdin || { echo "Docker 레지스트리 인증 실패"; exit 1; }

echo "인증 완료"
