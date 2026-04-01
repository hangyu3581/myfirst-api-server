# 01.springboot

## 이 코드는 무엇을 위한 실습인가?
- Spring Boot 애플리케이션을 컨테이너로 빌드하고 Kubernetes에 배포하는 실습 코드입니다.
- JPA 기반 API, Actuator/Prometheus, 프로브(liveness/readiness), ConfigMap/Secret/PVC/Ingress 구성을 함께 연습합니다.

## 이 디렉토리 기준 구조/파일 설명
- `src/main/java/`: API, 서비스, 도메인, 리포지토리 등 백엔드 애플리케이션 코드
- `src/main/resources/`: 실행 설정 파일(`application*.yaml`)과 정적 리소스
- `pom.xml`: Maven 의존성/빌드 설정(Spring Boot, JPA, Actuator 등)
- `Dockerfile`: Spring Boot JAR 이미지를 만드는 컨테이너 설정
- `docker-build.sh`, `docker-push.sh`: 이미지 빌드/푸시 스크립트
- `k8s/`: Deployment/Service/Ingress/PVC/Probe 실습용 매니페스트
- `kustomize/`: Kustomize 기반 배포 구성(base/overlay)
- `application-prod.yaml`, `env.properties`, `createcm.sh`: 운영 프로파일/환경값/ConfigMap 생성 보조 파일

## 학습 가이드(추천 순서)
- 1) `mvnw`와 `pom.xml`로 로컬 실행/빌드 확인
- 2) `Dockerfile` + `docker-build.sh`로 이미지 생성
- 3) `k8s/deploy.yaml`, `k8s/service.yaml`로 기본 배포
- 4) `k8s/deploy-with-probe.yaml`과 `ingress.yaml`로 운영 기능 확장
- 5) `kustomize/`로 환경별 배포 방식 연습
