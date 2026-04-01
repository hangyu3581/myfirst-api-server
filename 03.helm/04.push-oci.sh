#!/bin/bash
# ============================================================
# 04-1.push-oci.sh
# 목적: Helm chart를 Harbor에 OCI 이미지 형태로 push
#       → Harbor UI에서 "Artifacts" (OCI) 탭에서 확인 가능
# 프로토콜: oci://  (helm push - Helm 내장 기능, 플러그인 불필요)
# 사용: bash 04-1.push-oci.sh
# ============================================================

set -xeu

CHART_NAME="myfirst-api-server"
CHART_VERSION="0.0.4"
CHART_DIR="./${CHART_NAME}"

HARBOR_HOST="amdp-registry.skala-ai.com"
HARBOR_PROJECT="skala25a"
HARBOR_USER="robot\$skala25a"
HARBOR_PASSWORD="1qB9cyusbNComZPHAdjNIFWinf52xaBJ"

# OCI push 대상 경로: oci://호스트/프로젝트/서브경로
OCI_REGISTRY="oci://${HARBOR_HOST}/${HARBOR_PROJECT}/helm-charts"

# ── 1) Harbor OCI 레지스트리 로그인 ──────────────────────────
echo "${HARBOR_PASSWORD}" | helm registry login ${HARBOR_HOST} \
  --username "${HARBOR_USER}" \
  --password-stdin \
  --insecure \
  || { echo "Harbor 로그인 실패"; exit 1; }

# ── 2) 차트 패키징 (.tgz 생성) ───────────────────────────────
helm package ${CHART_DIR} --version ${CHART_VERSION}
CHART_PKG="${CHART_NAME}-${CHART_VERSION}.tgz"

# ── 3) OCI 방식으로 push ─────────────────────────────────────
helm push ${CHART_PKG} ${OCI_REGISTRY}

echo ""
echo "=== Push 완료 ==="
echo "위치: ${OCI_REGISTRY}/${CHART_NAME}:${CHART_VERSION}"

# ── 4) 확인: OCI chart 메타데이터 조회 ───────────────────────
helm show chart ${OCI_REGISTRY}/${CHART_NAME} --version ${CHART_VERSION}
