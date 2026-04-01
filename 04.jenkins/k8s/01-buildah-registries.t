apiVersion: v1
kind: ConfigMap
metadata:
  name: ${USER_NAME}-buildah-registries-conf
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}-jenkins
    component: buildah-config
data:
  registries.conf: |
    unqualified-search-registries = ["docker.io","quay.io","registry.fedoraproject.org"]

  containers.conf: |
    [network]
    network_backend = "cni"
