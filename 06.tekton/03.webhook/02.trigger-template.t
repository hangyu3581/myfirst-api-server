apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: ${USER_NAME}-springboot-trigger-template
  namespace: skala-tekton
spec:
  params:
    - name: git-url
      description: Git repository URL
    - name: git-revision
      description: Git branch/revision to checkout
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: ${USER_NAME}-ci-pipeline-run-
      spec:
        serviceAccountName: ${USER_NAME}-pipeline-sa
        pipelineRef:
          name: ci-pipeline
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
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
            value: "false"
          - name: git-user-name
            value: ${GIT_USERNAME}
          - name: git-user-email
            value: "skala@skala-ai.com"
        workspaces:
          - name: shared-workspace # 소스코드, 빌드산출물
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
          - name: maven-settings # settings.xml
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
          - name: maven-local-repo # m2 repository
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
        podTemplate:
          securityContext:
            fsGroup: 0
            runAsUser: 0
            runAsGroup: 0
