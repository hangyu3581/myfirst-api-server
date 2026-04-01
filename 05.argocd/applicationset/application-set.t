apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: ${USER_NAME}-myfirst-app-set
  namespace: skala-argocd
spec:
  generators:
  - list:
      elements:
      - environment: stage
        path: k8s/stage
        server: https://96BD83E8CE5CE0396D006BC5CEB350B0.gr7.ap-northeast-2.eks.amazonaws.com
        namespace: skala-stage
      - environment: prod
        path: k8s/prod
        server: https://96BD83E8CE5CE0396D006BC5CEB350B0.gr7.ap-northeast-2.eks.amazonaws.com
        namespace: skala-prod
  template:
    metadata:
      name: ${USER_NAME}-myfirst-api-server-{{environment}}
      namespace: skala-argocd
    spec:
      destination:
        namespace: '{{namespace}}'
        server: '{{server}}'
      project: ${ARGO_PROJECT}
      source:
        path: '{{path}}'
        repoURL: https://${GIT_REPO_URL}
        targetRevision: gitops
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - PrunePropagationPolicy=background

