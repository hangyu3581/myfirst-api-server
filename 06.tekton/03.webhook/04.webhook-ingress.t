apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  name: ${USER_NAME}-tekton-webhook-ingress
  namespace: skala-tekton
spec:
  ingressClassName: public-nginx
  rules:
  - host: tekton-trigger.skala25a.project.skala-ai.com
    http:
      paths:
      - backend:
          service:
            name: el-${USER_NAME}-springboot-listener
            port:
              number: 8080
        path: /${USER_NAME}/webhook
        pathType: Prefix
  tls:
  - hosts:
    - 'tekton-trigger.skala25a.project.skala-ai.com'
    secretName: skala25-project-tls-cert
