apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USER_NAME}-pipeline-sa-rb
subjects:
- kind: ServiceAccount
  name: ${USER_NAME}-pipeline-sa
  namespace: skala-tekton
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

