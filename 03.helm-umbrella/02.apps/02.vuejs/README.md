# 02.vuejs

## 이 코드는 무엇을 위한 실습인가?
- Vue 3 + Vite 기반 프런트엔드를 컨테이너로 배포하는 실습 코드입니다.
- 정적 리소스를 Nginx로 서빙하고, 환경(dev/prd)별 빌드/배포 흐름을 연습합니다.

## 이 디렉토리 기준 구조/파일 설명
- `src/`: Vue 애플리케이션 소스(컴포넌트/라우팅/화면 로직)
- `public/`: 정적 자원(아이콘, 이미지 등)
- `package.json`: 프런트엔드 의존성 및 실행/빌드 스크립트
- `vite.config.js`: Vite 설정(개발 서버/프록시/alias)
- `.env.dev`, `.env.prd`: 환경별 변수 파일
- `default.conf`: Nginx 설정
- `Dockerfile`: Vue 빌드 결과를 서빙하는 컨테이너 이미지 설정
- `docker-build.sh`, `docker-push.sh`: 이미지 빌드/푸시 스크립트
- `k8s/`: Deployment/Service 배포 매니페스트

## 학습 가이드(추천 순서)
- 1) `package.json` 스크립트로 로컬 개발 서버 확인
- 2) `.env.dev`, `.env.prd` 차이 확인 후 환경별 빌드
- 3) `Dockerfile`로 정적 배포 이미지 생성
- 4) `k8s/` 매니페스트로 컨테이너 배포

## vue pipeline 구성 시 빌드 시간 최소화 방법
local에서 build 한 ./disk 파일을 git hub에 push 하고 
이것을 Dockerfile에서 복사하도록 구성하기
