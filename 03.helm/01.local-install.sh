#!/bin/bash
# ============================================================
# 01.install-1.0.0.sh
# 목적: 로컬 chart(myfirst-api-server)를 사용해 1.0.0 최초 설치
# 사용: bash 01.install-1.0.0.sh
# ============================================================

set -xeu

USER_NAME="sk199"           # 리소스 이름 prefix
RELEASE_NAME="${USER_NAME}-myfirst-api"
NAMESPACE="skala-practice"
CHART_DIR="./myfirst-api-server"    # 로컬 chart 경로

# ── 1) 설치 (이미 있으면 upgrade, 없으면 install) ────────────
# -f values.yaml  → image.tag = 1.0.0 (기본값)
helm upgrade --install ${RELEASE_NAME} ${CHART_DIR} \
  --namespace ${NAMESPACE} \
  --set userName=${USER_NAME} \
  --atomic \
  --timeout 3m

# ── 3) 설치 결과 확인 ────────────────────────────────────────
echo ""
echo "=== Helm 릴리즈 목록 ==="
helm list -n ${NAMESPACE}

echo ""
echo "=== 배포된 리소스 ==="
kubectl get deploy,svc,ingress -n ${NAMESPACE} \
  -l app.kubernetes.io/instance=${RELEASE_NAME}
