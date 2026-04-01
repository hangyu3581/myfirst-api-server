apiVersion: v1
kind: Service
metadata:
  name: ${USER_NAME}-jenkins
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}-jenkins
spec:
  selector:
    app: ${USER_NAME}-jenkins
  ports:
    - name: http
      protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
---
# Jenkins JNLP Agent 연결 전용 서비스
# Kubernetes 동적 Pod 에이전트가 컨트롤러에 접속하는 채널
apiVersion: v1
kind: Service
metadata:
  name: ${USER_NAME}-jenkins-agent
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}-jenkins
spec:
  selector:
    app: ${USER_NAME}-jenkins
  ports:
    - name: jnlp
      protocol: TCP
      port: 50000
      targetPort: 50000
  type: ClusterIP
