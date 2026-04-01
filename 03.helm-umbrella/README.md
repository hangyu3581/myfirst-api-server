# 06.myapp-helm

## 이 저장소는 무엇을 위한 실습인가?

Spring Boot, Vue.js, Python, MariaDB 4개 애플리케이션을 **Helm Chart**로 통합 배포하는 실습입니다.  
`01.umbrella-chart`에서 Umbrella Helm Chart 구조를 익히고, `02.apps`에서 각 앱의 소스/Docker/K8s 원본을 참고합니다.

---

## 디렉토리 구조

```
03.helm-umbrella/
├── 01.umbrella-chart/   # Umbrella Helm Chart (핵심 실습)
└── 02.apps/             # 개별 앱 소스 및 원본 K8s 매니페스트 참고용
    ├── 01.springboot/
    ├── 02.vuejs/
    ├── 03.python/
    └── 04.mariadb/
```

---

## 01.umbrella-chart — Umbrella Helm Chart

Spring Boot, Vue.js, Python, MariaDB를 **하나의 Helm Chart**로 통합 배포합니다.

### 차트 구조

```
01.umbrella-chart/
├── Chart.yaml              # 부모 차트 메타정보 + MariaDB bitnami 의존성
├── values.yaml             # 전역 설정 (userName, namespace, 각 앱 설정)
├── templates/
│   └── NOTES.txt           # helm install/upgrade 후 출력되는 안내 메시지
└── charts/
    ├── springboot/         # Spring Boot API Server 서브차트
    │   └── templates/      #   deployment, service, ingress
    ├── vuejs/              # Vue.js Frontend 서브차트
    │   └── templates/      #   deployment, service
    ├── python/             # Python FastAPI 서브차트
    │   └── templates/      #   deployment, service
    └── mariadb-20.5.5.tgz  # Bitnami MariaDB (helm dependency update로 다운로드)
```

### 핵심 설계 원칙

| 항목 | 내용 |
|------|------|
| `global.userName` | 단 하나의 값으로 모든 리소스 이름 접두어 결정 (`sk199-...`) |
| `global.appImageRegistry` | Bitnami `global.imageRegistry` 충돌 방지를 위해 별도 키 사용 |
| MariaDB | Bitnami 공식 차트 dependency로 관리 (Debezium CDC Binlog 설정 포함) |
| Ingress | 사용자별 독립 도메인 (`sk<번호>-ingress.<baseDomain>`) |

### 생성되는 리소스 (userName=199 기준)

| 서비스 | 종류 | 리소스 이름 |
|--------|------|-------------|
| Spring Boot | Deployment, Service, Ingress | `sk199-myfirst-api-server` |
| Vue.js | Deployment, Service | `sk199-myfirst-frontend` |
| Python | Deployment, Service | `sk199-my-app-python` |
| MariaDB | StatefulSet, Service | `<release>-mariadb` |

### 사용 방법

```bash
# 1. MariaDB bitnami 의존성 다운로드 (최초 1회)
cd 01.umbrella-chart
helm dependency update

# 2. 설치 (userName=199 기본값)
helm upgrade --install myfirst-helm ./01.umbrella-chart \
  --namespace skala-practice \
  --create-namespace

# 3. userName 변경 (예: 200)
helm upgrade --install myfirst-helm ./01.umbrella-chart \
  --namespace skala-practice \
  --set global.userName=200

# 4. 렌더링 확인 (dry-run, 클러스터 미적용)
helm template myfirst-helm ./01.umbrella-chart --set global.userName=199

# 5. 배포 후 안내 메시지 재확인
helm get notes myfirst-helm -n skala-practice

# 6. 삭제
helm uninstall myfirst-helm --namespace skala-practice
```

### 주요 values.yaml 설정

```yaml
global:
  userName: "199"           # ← 이 값만 변경하면 모든 리소스가 sk<번호>-... 로 생성됨
  namespace: "skala-practice"
  appImageRegistry: "amdp-registry.skala-ai.com/skala25a"

springboot:
  spring:
    profilesActive: "local" # prod 전환 시 변경

mariadb:
  enabled: true             # false로 설정하면 MariaDB 배포 제외
```

---

## 02.apps — 개별 앱 원본 (참고용)

각 서비스의 소스코드, Dockerfile, 원본 K8s 매니페스트가 있습니다.  
`01.umbrella-chart`의 Helm 템플릿을 이해하거나 개별 배포가 필요할 때 참고합니다.

| 디렉토리 | 기술 스택 | 주요 내용 |
|----------|-----------|-----------|
| `01.springboot` | Spring Boot 3, Java | REST API, Actuator(health/metrics), Ingress, k8s 매니페스트 |
| `02.vuejs` | Vue 3, Vite, Nginx | SPA 프런트엔드, Nginx 서빙, k8s 매니페스트 |
| `03.python` | Python, FastAPI | health/metrics 엔드포인트, `-f/--file` 옵션 지원 docker-build.sh |
| `04.mariadb` | MariaDB 11.4, Bitnami | Debezium CDC Binlog 설정, Prometheus metrics, 초기화 SQL |

### 개별 앱 Docker 이미지 빌드

```bash
# Spring Boot
cd 02.apps/01.springboot && ./docker-build.sh && ./docker-push.sh

# Vue.js
cd 02.apps/02.vuejs && ./docker-build.sh && ./docker-push.sh

# Python (Dockerfile 지정 가능)
cd 02.apps/03.python && ./docker-build.sh              # 기본 Dockerfile
cd 02.apps/03.python && ./docker-build.sh -f Dockerfile.base  # 베이스 이미지 빌드

# MariaDB (Helm 단독 설치)
cd 02.apps/04.mariadb && ./install.sh
```

