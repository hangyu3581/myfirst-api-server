#!/bin/bash

USER_NAME=sk199
NAMESPACE="skala-practice"

# 현재 리비전 확인
helm history ${USER_NAME}-mariadb --namespace ${NAMESPACE}

# 예: 2번 리비전으로 롤백
#helm rollback chroma 2 --namespace chromadb

