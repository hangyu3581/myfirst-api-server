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
      storage: 5Gi
  storageClassName: efs-sc-ap  #amdp-dev-efs

