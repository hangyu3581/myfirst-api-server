apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${USER_NAME}-jenkins-ingress
  namespace: ${NAMESPACE}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    # 대용량 파일 업로드(Pipeline 아티팩트)를 위해 body 크기 제한 해제
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    # WebSocket (Pipeline 실시간 로그 스트리밍) 지원
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
spec:
  ingressClassName: public-nginx
  rules:
    - host: ${USER_NAME}-jenkins.skala25a.project.skala-ai.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${USER_NAME}-jenkins
                port:
                  number: 8080
  tls:
    - hosts:
        - ${USER_NAME}-jenkins.skala25a.project.skala-ai.com
      secretName: ${USER_NAME}-jenkins-tls-cert
