apiVersion: v1
kind: Pod
metadata:
  name: ${USER_NAME}-kaniko-pod-springboot
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}
spec:
  # Init Container: Maven 빌드
  initContainers:
  - name: build
    image: maven:3.8.5-openjdk-17
    workingDir: /workspace
    command: ["/bin/bash"]
    args:
      - -c
      - |
        echo "=== Git Clone 시작 ==="
        git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_REPO_URL} .
        echo "=== Maven 빌드 시작 ==="
        mvn clean install -DskipTests
        echo "=== 빌드 완료 ==="
        ls -al

    volumeMounts:
      - name: workspace
        mountPath: /workspace

  # Main Container: Kaniko 빌드 (기본 entrypoint만 사용)
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    # command 없음 - 기본 entrypoint(/kaniko/executor) 사용
    args:
      - --dockerfile=/workspace/Dockerfile
      - --context=dir:///workspace
      - --destination=${DOCKER_REGISTRY}/${USER_NAME}-${IMAGE_NAME}:${VERSION}.spring-kaniko-kube
      - --verbosity=debug
    volumeMounts:
      - name: workspace
        mountPath: /workspace
      - name: kaniko-secret
        mountPath: /kaniko/.docker
        readOnly: true

  restartPolicy: Never
  volumes:
    - name: workspace
      emptyDir: {}
    - name: kaniko-secret
      secret:
        secretName: harbor-registry-secret
        items:
          - key: .dockerconfigjson
            path: config.json
