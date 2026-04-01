apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${USER_NAME}-jenkins
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}-jenkins
spec:
  # Jenkins 컨트롤러는 단일 레플리카 운영
  # (Active-Active HA 는 별도 플러그인 없이 지원 불가)
  replicas: 1
  selector:
    matchLabels:
      app: ${USER_NAME}-jenkins
  template:
    metadata:
      labels:
        app: ${USER_NAME}-jenkins
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/prometheus"
    spec:
      serviceAccountName: skala-admin-sa
      containers:
        - name: jenkins
          image: amdp-registry.skala-ai.com/library/skala-new-jenkins:1.1
          imagePullPolicy: Always   # Dockerfile 재빌드 후 동일 태그로 push해도 최신 이미지 사용
          ports:
            - name: http
              containerPort: 8080
            - name: jnlp
              containerPort: 50000

          env:
            - name: KUBECONFIG
              value: ""   # Dockerfile KUBECONFIG 빈값으로 오버라이드 → in-cluster SA 토큰 사용
            - name: JENKINS_OPTS
              value: "--httpPort=8080"
            - name: JAVA_OPTS
              value: >-
                -Xms512m
                -Xmx4096m
                -Djenkins.install.runSetupWizard=false
                -Djenkins.CLI.disabled=true
                -Djenkins.security.ApiTokenProperty.adminCanGenerateNewTokens=true
                -Dhudson.slaves.NodeProvisioner.initialDelay=0
                -Dhudson.slaves.NodeProvisioner.MARGIN=50
                -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85
            - name: CASC_JENKINS_CONFIG
              value: /var/jenkins_config/jenkins.yaml

          volumeMounts:
            - name: jenkins-home
              mountPath: /var/jenkins_home
            - name: jenkins-config
              mountPath: /var/jenkins_config

          resources:
            requests:
              cpu: "1000m"
              memory: "2Gi"
            limits:
              cpu: "2000m"
              memory: "4Gi"

          securityContext:
            privileged: true    # buildah이 컨테이너 빌드 시 필요한 권한 (agent any + buildah)

          livenessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 15
            timeoutSeconds: 10
            failureThreshold: 10

          readinessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 10

      volumes:
        - name: jenkins-home
          persistentVolumeClaim:
            claimName: ${USER_NAME}-jenkins-pvc
        - name: jenkins-config
          configMap:
            name: ${USER_NAME}-jenkins-config
