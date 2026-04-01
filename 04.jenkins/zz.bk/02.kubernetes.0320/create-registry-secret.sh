#!/bin/bash


# 기존 시크릿 삭제
kubectl delete secret harbor-registry-secret -n skala-tekton --ignore-not-found

# 올바른 사용자명으로 시크릿 생성
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=amdp-registry.skala-ai.com \
  --docker-username="robot$skala25a" \
  --docker-password="1qB9cyusbNComZPHAdjNIFWinf52xaBJ" \
  --docker-email=dev@skala.ai \
  --namespace=skala-tekton

# Tekton 어노테이션 추가
kubectl annotate secret harbor-registry-secret \
  tekton.dev/docker-0=amdp-registry.skala-ai.com \
  -n skala-tekton
