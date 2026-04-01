apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${USER_NAME}-myfirst-api-server
  namespace: skala-argocd
spec:
  destination:
    namespace: ${NAMESPACE}
    server: https://96BD83E8CE5CE0396D006BC5CEB350B0.gr7.ap-northeast-2.eks.amazonaws.com
  project: ${ARGO_PROJECT}
  source:
    path: k8s
    repoURL: https://${GIT_REPO_URL}
    targetRevision: gitops
  syncPolicy:
    syncOptions:
    - PrunePropagationPolicy=background
