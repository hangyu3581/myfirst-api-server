apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${USER_NAME}-helm-my-app
  namespace: skala-argocd
spec:
  destination:
    namespace: ${NAMESPACE}
    server: https://96BD83E8CE5CE0396D006BC5CEB350B0.gr7.ap-northeast-2.eks.amazonaws.com
  project: ${ARGO_PROJECT}
  source:
    repoURL: https://github.com/himang10/mychart.git
    targetRevision: HEAD
    path: .
    helm:
      valueFiles:
        - custom-values.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - PrunePropagationPolicy=background
