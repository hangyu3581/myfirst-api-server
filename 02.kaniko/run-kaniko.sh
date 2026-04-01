#!/bin/bash

IMG_TAG=python-kaniko

# 첫 번째 인자로 CPU 플랫폼 설정 (기본값: amd64)
if [ "${1:-}" = "arm64" ]; then
  CPU_PLATFORM=arm64
  IMG_TAG=${CPU_PLATFORM}-${IMG_TAG}
else
  CPU_PLATFORM=amd64
fi


ENV_PROPERTIES=../env.properties

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

# 인증 설정 파일 생성
mkdir -p auth
cat > auth/config.json <<EOF
{
  "auths": {
    "amdp-registry.skala-ai.com": {
      "username": "${DOCKER_REGISTRY_USER}",
      "password": "${DOCKER_REGISTRY_PASSWORD}",
      "auth": "$(echo -n "$DOCKER_REGISTRY_USER:$DOCKER_REGISTRY_PASSWORD" | base64)"
    }
  }
}
EOF

# 현재 디렉토리의 절대 경로 구하기
CURRENT_DIR=$(pwd)

# docker run으로 kaniko 실행
# gcr.io/kaniko-project/executor:latest \
docker run --rm \
  -v "${CURRENT_DIR}:/workspace" \
  -v "${CURRENT_DIR}/auth/config.json:/kaniko/.docker/config.json" \
  amdp-registry.skala-ai.com/library/executor:latest \
  --dockerfile=/workspace/Dockerfile \
  --context=dir:///workspace \
  --destination=${DOCKER_REGISTRY}/${USER_NAME}-${IMAGE_NAME}:${VERSION}.${IMG_TAG} \
  --custom-platform=linux/${CPU_PLATFORM}

# 정리
rm -rf auth
