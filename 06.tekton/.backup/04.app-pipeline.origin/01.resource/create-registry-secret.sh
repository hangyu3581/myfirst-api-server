#!/bin/bash

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=amdp-registry.skala-ai.com \
  --docker-username="robot\$skala-professor" \
  --docker-password="UNYMp8t89kwIIMwsSmOJJ9d3pMoy14n8" \
  --namespace=skala-tekton
