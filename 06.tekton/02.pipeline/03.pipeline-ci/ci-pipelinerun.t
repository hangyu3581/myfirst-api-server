apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: ${USER_NAME}-ci-pipeline-run-${HASHCODE}
  namespace: skala-tekton
spec:
  serviceAccountName: ${USER_NAME}-pipeline-sa
  pipelineRef:
    name: ci-pipeline
  params:
    - name: git-url
      value: https://${GIT_REPO_URL}
    - name: git-revision
      value: ${GIT_REVISION}
    - name: image-registry-url
      value: "amdp-registry.skala-ai.com"
    - name: image-registry-project
      value: "skala25a"
    - name: image-name
      value: ${USER_NAME}-${IMAGE_NAME}
    - name: image-tag
      value: ${VERSION}
    - name: dockerfile
      value: "Dockerfile"
    - name: context
      value: "."
    - name: k8s-deploy-path
      value: "k8s/deploy.yaml"
    - name: skip-tls-verify-registry
      value: "false"   # 필요하면 "true"
    - name: git-user-name
      value: ${GIT_USERNAME}
    - name: git-user-email
      value: "skala@skala-ai.com"
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
  podTemplate:
    securityContext:
      fsGroup: 0
      runAsUser: 0
      runAsGroup: 0
  serviceAccountName: ${USER_NAME}-pipeline-sa
