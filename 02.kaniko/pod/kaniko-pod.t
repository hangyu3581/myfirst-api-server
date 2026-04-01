apiVersion: v1
kind: Pod
metadata:
  name: ${USER_NAME}-kaniko-pod-python
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      args:
        - --dockerfile=/workspace/Dockerfile
        - --context=dir:///workspace
        - --destination=${DOCKER_REGISTRY}/${USER_NAME}-${IMAGE_NAME}:${VERSION}.python-kaniko-kube
      volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
        - name: workspace
          mountPath: /workspace
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: harbor-registry-secret
        items:
          - key: .dockerconfigjson
            path: config.json   # /kaniko/.docker/config.json 로 마운트됨
    - name: workspace
      configMap:   # 또는 PVC, emptyDir, gitRepo 등 원하는 소스로 교체 가능
        name: ${USER_NAME}-app-workspace
