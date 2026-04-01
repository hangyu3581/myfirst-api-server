#!/bin/bash
# ============================================================
# 05.install-harbor.sh
# 목적: Harbor Helm Chart Repository에서 chart를 받아 설치
#       04-2.push-harbor.sh로 push한 chart를 대상으로 함
# 조건: 04-2.push-harbor.sh 실행 이후에 동작
# 사용: bash 05.install-harbor.sh
# ============================================================

set -xeu

USER_NAME="sk199"
CHART_NAME="myfirst-api-server"
CHART_VERSION="0.0.3"
RELEASE_NAME="${USER_NAME}-myfirst-api"
NAMESPACE="skala-practice"

HARBOR_HOST="amdp-registry.skala-ai.com"
HARBOR_PROJECT="skala25a"
HARBOR_USER="robot\$skala25a"
HARBOR_PASSWORD="1qB9cyusbNComZPHAdjNIFWinf52xaBJ"

CHART_REPO_URL="https://${HARBOR_HOST}/chartrepo/${HARBOR_PROJECT}"
REPO_NAME="${HARBOR_PROJECT}-charts"

# ── 1) Helm repo 등록 (없으면 추가) ─────────────────────────
if ! helm repo list 2>/dev/null | grep -q "^${REPO_NAME}"; then
  helm repo add ${REPO_NAME} ${CHART_REPO_URL} \
    --username "${HARBOR_USER}" \
    --password "${HARBOR_PASSWORD}" \
    --insecure-skip-tls-verify
fi

helm repo update ${REPO_NAME}

# ── 2) 설치 가능한 버전 확인 ─────────────────────────────────
echo "=== 사용 가능한 chart 버전 ==="
helm search repo ${REPO_NAME}/${CHART_NAME} --versions

# ── 3) namespace 없으면 생성 ─────────────────────────────────
kubectl get namespace ${NAMESPACE} >/dev/null 2>&1 \
  || kubectl create namespace ${NAMESPACE}

# ── 4) Harbor repo에서 chart 설치 ────────────────────────────
helm upgrade --install ${RELEASE_NAME} \
  ${REPO_NAME}/${CHART_NAME} \
  --version ${CHART_VERSION} \
  --namespace ${NAMESPACE} \
  --set userName=${USER_NAME} \
  --atomic \
  --timeout 3m

# ── 5) 설치 결과 확인 ────────────────────────────────────────
echo ""
echo "=== 설치된 릴리즈 ==="
helm list -n ${NAMESPACE}

echo ""
echo "=== 배포된 리소스 ==="
kubectl get deploy,svc,ingress -n ${NAMESPACE} \
  -l app.kubernetes.io/instance=${RELEASE_NAME}
