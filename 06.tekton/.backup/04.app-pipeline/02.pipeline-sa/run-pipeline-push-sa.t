apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: ${USER_NAME}-push-run-sa-${HASHCODE}
  namespace: skala-tekton
spec:
  pipelineRef:
    name: push-pipeline-sa
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
    - name: maven-settings
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
    - name: maven-local-repo
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
  podTemplate:
    securityContext:
      fsGroup: 0  # 볼륨을 사용하는 그룹 ID
      runAsUser: 0  # Pod를 실행하는 사용자 ID
      runAsGroup: 0  # Pod를 실행하는 그룹 ID
  params:
    - name: git-url
      value: "https://github.com/rde-devplace/devops-source.git"
    - name: git-revision
      value: "main"
    - name: image-registry
      value: "amdp-registry.skala-ai.com/skala25a"
    - name: image-name
      value: "${USER_NAME}-my-app"
    - name: image-tag
      value: "1.0.kaniko-docker"
  serviceAccountName: ${USER_NAME}-pipeline-sa
