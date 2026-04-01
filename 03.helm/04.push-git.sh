#!/bin/bash
# ============================================================
# 목적: Helm chart를 GitHub Pages 기반 Helm Chart Repository에 push
#       → https://himang10.github.io/mycharts 에서 서빙
# 전제: mycharts git repo가 로컬에 clone되어 있어야 함
#       예) git clone https://github.com/himang10/mycharts
# 사용: bash 04-3.push-git.sh
# ============================================================

set -xeu

BRANCH="main"
CHART_NAME="myfirst-api-server"
CHART_VERSION="0.0.2"
CHART_DIR="./myfirst-api-server"

# GitHub Pages Helm repo 로컬 경로 (git clone된 위치)
PAGES_URL="https://himang10.github.io/mycharts"

# ── 1) 차트 패키징 (.tgz 생성) ───────────────────────────────
helm package ${CHART_DIR} --version ${CHART_VERSION}
CHART_PKG="${CHART_NAME}-${CHART_VERSION}.tgz"

# ── 2) .tgz를 git repo 디렉토리로 복사 ───────────────────────

# ── 3) index.yaml 생성 (base url 포함) ───────────────────────
# index.yaml: 이 repo에 있는 모든 .tgz를 스캔해 chart 목록 생성
# --url: helm repo add 시 .tgz를 다운로드할 base URL
helm repo index . --url ${PAGES_URL}

echo ""
echo "=== 생성된 index.yaml 내용 ==="
cat index.yaml

# ── 4) git push → GitHub Pages 배포 ─────────────────────────
git add .
git commit -m "add ${CHART_NAME}-${CHART_VERSION}"
git push origin ${BRANCH}

echo ""
echo "=== Push 완료 ==="
echo "잠시 후 아래 명령으로 설치 가능합니다:"
echo "  helm repo add myrepo ${PAGES_URL}"
echo "  helm repo update"
echo "  helm install my-release myrepo/${CHART_NAME} --version ${CHART_VERSION}"
