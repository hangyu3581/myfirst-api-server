apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${USER_NAME}-my-app-kustomize
  namespace: skala-argocd
spec:
  destination:
    namespace: ${NAMESPACE}
    server: https://96BD83E8CE5CE0396D006BC5CEB350B0.gr7.ap-northeast-2.eks.amazonaws.com
  project: ${ARGO_PROJECT}
  source:
    path: kustomize/overlays/dev
    repoURL: https://github.com/rde-devplace/devops-source.git
    targetRevision: HEAD        # 예: HEAD, main, gitops 등
    kustomize: {}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - PrunePropagationPolicy=background
