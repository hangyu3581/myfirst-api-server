apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: deploy-pipeline
  namespace: skala-tekton
spec:
  params:
    - name: git-url
      type: string
      description: "Git repository URL"
    - name: git-revision
      type: string
      default: "main"
      description: "Git branch to checkout"
    - name: image-registry
      type: string
      description: "Docker image registry"
    - name: image-name
      type: string
      description: "Docker image name"
    - name: image-tag
      type: string
      default: "latest"
      description: "Docker image tag"
    - name: maven-image
      type: string
      default: "maven:3.9.6-eclipse-temurin-17"
  workspaces:
    - name: shared-workspace   # 소스코드, 빌드산출물
    - name: maven-settings     # settings.xml
    - name: maven-local-repo   # m2 repository
    - name: kubeconfig-dir     # kubeconfig
    - name: docker-credentials # Docker 인증 정보
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
        kind: Task
      params:
        - name: url
          value: "$(params.git-url)"
        - name: revision
          value: "$(params.git-revision)"
      workspaces:
        - name: output
          workspace: shared-workspace

    - name: maven-build
      taskRef:
        name: maven
        kind: Task
      runAfter:
        - git-clone
      params:
        - name: MAVEN_IMAGE
          value: "$(params.maven-image)"
        - name: GOALS
          value:
            - "clean"
            - "package"
            - "-DskipTests"
      workspaces:
        - name: source
          workspace: shared-workspace
        - name: maven-settings
          workspace: maven-settings
        - name: maven-local-repo
          workspace: maven-local-repo

    - name: kaniko-build-push
      taskRef:
        name: kaniko
        kind: Task
      runAfter:
        - maven-build
      params:
        - name: DOCKERFILE
          value: "Dockerfile"
        - name: IMAGE
          value: "$(params.image-registry)/$(params.image-name):$(params.image-tag)"
      workspaces:
        - name: source
          workspace: shared-workspace
    - name: k8s-deploy
      taskRef:
        name: kubernetes-actions
      runAfter:
        - kaniko-build-push
      params:
        - name: script
          value: |
            kubectl apply -f $(workspaces.manifest-dir.path)/k8s
            kubectl get deployment
      workspaces:
        - name: manifest-dir
          workspace: shared-workspace
        - name: kubeconfig-dir   
          workspace: kubeconfig-dir


