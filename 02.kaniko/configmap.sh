#!/bin/bash

ENV_PROPERTIES=../env.properties
# Target
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

kubectl create configmap ${USER_NAME}-app-workspace \
  --from-file=Dockerfile=./Dockerfile \
  --from-file=fastserver.py=./fastserver.py \
  --namespace ${NAMESPACE}
