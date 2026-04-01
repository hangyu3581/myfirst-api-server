apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${USER_NAME}-pipeline-sa
  namespace: skala-tekton
secrets:
  - name: harbor-registry-secret  # 기존 Docker Registry 인증 정보
  - name: ${USER_NAME}-github-credentials  # GitHub 인증 정보 추가
imagePullSecrets:
  - name: harbor-registry-secret  # Kaniko가 이 Secret을 사용하도록 설정
