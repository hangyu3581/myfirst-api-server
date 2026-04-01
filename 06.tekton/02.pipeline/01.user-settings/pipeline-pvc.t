apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${USER_NAME}-shared-workspace-pvc
  namespace: skala-tekton
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: ${PVC_STORAGE_SIZE}
  storageClassName: ${PVC_STORAGE_CLASS}

