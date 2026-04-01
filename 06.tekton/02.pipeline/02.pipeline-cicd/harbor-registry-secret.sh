kubectl delete secret harbor-registry-secret -n skala-tekton --ignore-not-found

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=amdp-registry.skala-ai.com \
  --docker-username="robot\$skala25a" \
  --docker-password="1qB9cyusbNComZPHAdjNIFWinf52xaBJ" \
  --docker-email=dev@skala.ai \
  --namespace=skala-tekton

# Tekton 어노테이션 추가
kubectl annotate secret harbor-registry-secret \
  tekton.dev/docker-0=amdp-registry.skala-ai.com \
  -n skala-tekton


kubectl get secret harbor-registry-secret -n skala-tekton -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq

