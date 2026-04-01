# 04.python

## 이 코드는 무엇을 위한 실습인가?
- FastAPI 기반 경량 API 서버를 컨테이너로 배포하는 실습 코드입니다.
- Health/Ready/Metrics/Prometheus 엔드포인트를 통해 Kubernetes 운영 포인트를 연습합니다.

## 이 디렉토리 기준 구조/파일 설명
- `fastserver.py`: FastAPI 서버 본체(healthz, ready, metrics, info 등)
- `Dockerfile.base`: Python 기반 베이스 이미지 생성용 설정
- `Dockerfile`: 베이스 이미지를 사용해 앱 코드를 포함하는 실행 이미지 설정
- `poetry-export-req.sh`: 의존성 내보내기/정리 보조 스크립트
- `docker-build.sh`, `docker-push.sh`, `base-docker-*.sh`: 이미지 빌드/푸시 스크립트
- `k8s/`: Deployment/Service 매니페스트

## 학습 가이드(추천 순서)
- 1) `fastserver.py` 엔드포인트(`healthz`, `ready`, `metrics`) 확인
- 2) `Dockerfile.base`로 베이스 이미지 개념 이해
- 3) `Dockerfile`로 앱 이미지 생성
- 4) `k8s/` 매니페스트로 배포 후 상태 점검
