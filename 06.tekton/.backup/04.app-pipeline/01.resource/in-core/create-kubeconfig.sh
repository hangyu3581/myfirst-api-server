#!/bin/bash

kubectl create configmap kubeconfig --from-file="$(pwd)/skala-practice-kubeconfig" -n skala-tekton

