#!/bin/bash

USER_NAME=sk199
NAMESPACE=skala-practice

helm upgrade ${USER_NAME}-mariadb bitnami/mariadb \
  --namespace ${NAMESPACE} \
  -f custom-values.yaml

