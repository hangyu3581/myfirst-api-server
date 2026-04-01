apiVersion: v1
kind: Secret
metadata:
  name: ${USER_NAME}-github-credentials
  namespace: skala-tekton  # 원하는 네임스페이스로 변경
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: "rde-devplace"
  password: "YOUR_GITHUB_PAT"
