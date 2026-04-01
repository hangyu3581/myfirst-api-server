apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: ${USER_NAME}-deploy-pipeline-run-${HASHCODE}
  namespace: skala-tekton
spec:
  pipelineRef:
    name: deploy-pipeline
  workspaces:
    - name: shared-workspace # 소스코드, 빌드산출물
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
    - name: maven-settings  # settings.xml
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
    - name: maven-local-repo  # m2 repository
      persistentVolumeClaim:
        claimName: ${USER_NAME}-shared-workspace-pvc  # shared-workspace PVC를 참조
    - name: kubeconfig-dir # kubeconfig
      configMap:
        name: kubeconfig
  podTemplate:
    securityContext:
      fsGroup: 0  # 볼륨을 사용하는 그룹 ID
      runAsUser: 0  # Pod를 실행하는 사용자 ID
      runAsGroup: 0  # Pod를 실행하는 그룹 ID
  params:
    - name: git-url
      value: https://${GIT_REPO_URL}
    - name: git-revision
      value: ${GIT_REVISION}
    - name: image-registry
      value: ${DOCKER_REGISTRY}
    - name: image-name
      value: ${USER_NAME}-${IMAGE_NAME}
    - name: image-tag
      value: ${VERSION}
  serviceAccountName: ${USER_NAME}-pipeline-sa
