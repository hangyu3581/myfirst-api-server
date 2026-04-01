#!/bin/bash

# 첫 번째 인자가 제공되면 사용하고, 없으면 기본값 "test" 사용
HELM_DIR=${1:-test}

# 디렉토리 존재 여부 확인 (선택사항)
if [ ! -d "$HELM_DIR" ]; then
    echo "Warning: Directory '$HELM_DIR' does not exist"
fi

echo "Running helm template for: $HELM_DIR"
helm template $HELM_DIR --debug --dry-run
