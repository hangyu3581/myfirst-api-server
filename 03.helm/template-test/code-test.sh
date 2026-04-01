#!/bin/bash

# 첫 번째 인자가 제공되면 사용하고, 없으면 기본값 "test" 사용
TEST_YAML=${1:-"templates/test1.yaml"}

# 디렉토리 존재 여부 확인 (선택사항)
if [ ! -f "$TEST_YAML" ]; then
    echo "Warning: Directory '$TEST_YAML' does not exist"
fi

echo "Running helm template for: $TEST_YAML"
helm template . --show-only $TEST_YAML
