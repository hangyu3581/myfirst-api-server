#!/bin/bash
# ============================================================
# 목적: GitHub Pages 기반 Helm Chart Repository에서 chart를 받아 설치
# repo: https://himang10.github.io/mycharts
# 사용: bash 05.install-git.sh
# ============================================================

set -xeu

USER_NAME="sk199"
CHART_NAME="myfirst-api-server"
RELEASE_NAME="${USER_NAME}-myfirst-api"
NAMESPACE="skala-practice"

REPO_NAME="myrepo"
REPO_URL="https://himang10.github.io/mycharts"

# ── 1) Helm repo 등록 (없으면 추가, 있으면 URL 갱신) ─────────
if helm repo list 2>/dev/null | grep -q "^${REPO_NAME}"; then
  helm repo remove ${REPO_NAME}
fi

helm repo add ${REPO_NAME} ${REPO_URL}

# ── 2) repo 최신 index.yaml 동기화 ───────────────────────────
helm repo update ${REPO_NAME}

# ── 3) 설치 가능한 버전 확인 ─────────────────────────────────
echo "=== 사용 가능한 chart 버전 ==="
helm search repo ${REPO_NAME}/${CHART_NAME} --versions

# ── 4) namespace 없으면 생성 ─────────────────────────────────
kubectl get namespace ${NAMESPACE} >/dev/null 2>&1 \
  || kubectl create namespace ${NAMESPACE}

# ── 5) GitHub Pages repo에서 chart 설치 ──────────────────────
helm upgrade --install ${RELEASE_NAME} \
  ${REPO_NAME}/${CHART_NAME} \
  --namespace ${NAMESPACE} \
  --set userName=${USER_NAME} \
  --atomic \
  --timeout 3m

# ── 6) 설치 결과 확인 ────────────────────────────────────────
echo ""
echo "=== 설치된 릴리즈 ==="
helm list -n ${NAMESPACE}

helm history ${CHART_NAME}}
echo ""
echo "=== 배포된 리소스 ==="
kubectl get deploy,svc,ingress -n ${NAMESPACE} \
  -l app.kubernetes.io/instance=${RELEASE_NAME}

