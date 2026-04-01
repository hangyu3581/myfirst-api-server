#!/bin/bash

USER_NAME="sk199"

kubectl create configmap ${USER_NAME}-myfirst-configmap \
  --from-file=application-prod.yaml \
  --namespace=skala-practice

