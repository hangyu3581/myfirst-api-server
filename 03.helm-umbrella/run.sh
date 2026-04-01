#!/bin/bash

USER_NAME=199
NAMESPACE=skala-practice

helm upgrade --install ${USER_NAME}-myfirst-helm ./myfirst-helm \
  --namespace ${NAMESPACE} \
  --set global.userName=${USER_NAME}
