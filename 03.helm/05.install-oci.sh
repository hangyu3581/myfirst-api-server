#!/bin/bash
# ============================================================
# 05.install-oci.sh
# 목적: Harbor OCI Registry에서 chart를 받아 설치
#       04-1.push-oci.sh로 push한 chart를 대상으로 함
# 프로토콜: oci://  (helm repo add 불필요, URL 직접 지정)
# 조건: 04-1.push-oci.sh 실행 이후에 동작
# 사용: bash 05.install-oci.sh
# ============================================================

set -xeu

USER_NAME="sk199"
CHART_NAME="myfirst-api-server"
CHART_VERSION="0.0.4"
RELEASE_NAME="${USER_NAME}-myfirst-api"
NAMESPACE="skala-practice"

HARBOR_HOST="amdp-registry.skala-ai.com"
HARBOR_PROJECT="skala25a"
HARBOR_USER="robot\$skala25a"
HARBOR_PASSWORD="1qB9cyusbNComZPHAdjNIFWinf52xaBJ"

# OCI chart 경로 (helm repo add 없이 URL 직접 사용)
OCI_CHART="oci://${HARBOR_HOST}/${HARBOR_PROJECT}/helm-charts/${CHART_NAME}"

# ── 1) Harbor OCI 레지스트리 로그인 ──────────────────────────
# OCI 방식은 helm registry login 사용 (helm repo add 미지원)
echo "${HARBOR_PASSWORD}" | helm registry login ${HARBOR_HOST} \
  --username "${HARBOR_USER}" \
  --password-stdin \
  --insecure \
  || { echo "Harbor OCI 로그인 실패"; exit 1; }

# ── 2) 설치할 chart 메타데이터 확인 ─────────────────────────
echo "=== chart 정보 ==="
helm show chart ${OCI_CHART} --version ${CHART_VERSION}

# ── 3) namespace 없으면 생성 ─────────────────────────────────
kubectl get namespace ${NAMESPACE} >/dev/null 2>&1 \
  || kubectl create namespace ${NAMESPACE}

# ── 4) OCI registry에서 chart 설치 ──────────────────────────
helm upgrade --install ${RELEASE_NAME} \
  ${OCI_CHART} \
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
