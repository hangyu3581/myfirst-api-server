#!/bin/bash
# ============================================================
# 목적: 2.0.0으로 업그레이드된 릴리즈를 1.0.0(revision 1)으로 롤백
# 조건: 02.upgrade-2.0.0.sh 실행 이후에 동작
# 사용: bash 03.rollback-1.0.0.sh
# ============================================================

set -xeu

USER_NAME="sk199"
RELEASE_NAME="${USER_NAME}-myfirst-api"
NAMESPACE="skala-practice"

# ── 1) 롤백 전 히스토리 확인 ─────────────────────────────────
echo "=== 롤백 전 히스토리 ==="
helm history ${RELEASE_NAME} -n ${NAMESPACE}

# ── 2) revision 1 (1.0.0)으로 롤백 ──────────────────────────
# rollback <릴리즈명> <되돌아갈 revision 번호>
# revision 0 지정 시 바로 이전 버전으로 롤백
helm rollback ${RELEASE_NAME} 1 \
  --namespace ${NAMESPACE} \
  --wait \
  --timeout 3m

# ── 3) 롤백 후 히스토리 확인 (revision 3으로 롤백 기록 추가됨) ─
echo ""
echo "=== 롤백 후 히스토리 ==="
echo "  ※ rollback은 새 revision으로 기록됩니다 (revision 3 = 1.0.0)"
helm history ${RELEASE_NAME} -n ${NAMESPACE}

echo ""
echo "=== 현재 실행 중인 이미지 태그 확인 (1.0.0으로 복구) ==="
kubectl get deploy -n ${NAMESPACE} \
  -l app.kubernetes.io/instance=${RELEASE_NAME} \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.template.spec.containers[0].image}{"\n"}{end}'

