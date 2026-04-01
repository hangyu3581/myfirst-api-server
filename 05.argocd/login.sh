#!/bin/bash
set -e

export ARGOCD_SERVER=argocd.skala25a.project.skala-ai.com:443
export ARGOCD_USERNAME=admin
export ARGOCD_PASSWORD=skala-argocd
export ARGOCD_INSECURE=true
export ARGOCD_GRPC_WEB=true

# 서버 주소 확인
if [ -z "$ARGOCD_SERVER" ]; then
  echo "Error: ARGOCD_SERVER environment variable is not set"
  exit 1
fi

# 인증 방법 선택
if [ ! -z "$ARGOCD_AUTH_TOKEN" ]; then
  # 토큰 기반 인증
  echo "Logging in with auth token..."
  argocd login --auth-token $ARGOCD_AUTH_TOKEN $ARGOCD_SERVER
elif [ ! -z "$ARGOCD_USERNAME" ] && [ ! -z "$ARGOCD_PASSWORD" ]; then
  # 사용자 이름/비밀번호 기반 인증
  echo "Logging in with username and password..."

  if [ "$ARGOCD_INSECURE" = "true" ]; then
    argocd login $ARGOCD_SERVER --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --insecure --grpc-web
  else
    argocd login $ARGOCD_SERVER --username $ARGOCD_USERNAME --password $ARGOCD_PASSWORD --grpc-web
  fi
else
  echo "Warning: No authentication method provided (token or username/password)"
  echo "You may need to manually login to ArgoCD server"
fi

# 로그인 상태 확인
argocd account get --grpc-web
