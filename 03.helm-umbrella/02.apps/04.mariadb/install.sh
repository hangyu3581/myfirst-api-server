#!/bin/bash

USER_NAME=sk199
NAMESPACE="skala-practice"

# Helm 저장소 추가
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install ${USER_NAME}-mariadb bitnami/mariadb \
  --namespace ${NAMESPACE} \
  --version 20.5.5 \
  -f custom-values.yaml
