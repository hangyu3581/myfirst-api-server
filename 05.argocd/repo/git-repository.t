apiVersion: v1
kind: Secret
metadata:
  name: ${USER_NAME}-git-repo
  namespace: skala-argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  name: ${USER_NAME}-my-app
  type: git
  url: https://${GIT_REPO_URL}
  username: ${GIT_USERNAME}
  project: ${ARGO_PROJECT}
  password: ${GIT_PASSWORD}
