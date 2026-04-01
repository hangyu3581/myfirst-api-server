#!/bin/bash

USER_NAME=sk199
NAMESPACE=skala-practice

helm uninstall ${USER_NAME}-mariadb --namespace ${NAMESPACE}
