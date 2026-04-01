# myfirst-helm (01.umbrella-chart)

Spring Boot API, Vue.js Frontend, Python App, MariaDB를 통합 배포하는 **Umbrella Helm Chart**

- **Chart Version**: 0.1.0
- **App Version**: 1.0.0

## 구조

```
01.umbrella-chart/
├── Chart.yaml              # 부모 차트 (MariaDB bitnami 의존성 포함)
├── values.yaml             # 전역 설정 (userName 등)
├── templates/
│   └── NOTES.txt           # helm install/upgrade 후 출력 메시지
└── charts/
    ├── springboot/         # Spring Boot API Server
    ├── vuejs/              # Vue.js Frontend
    ├── python/             # Python FastAPI App
    └── mariadb-20.5.5.tgz  # Bitnami MariaDB (dependency)
```

## 필수 설정 값

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `global.userName` | `"199"` | 사용자 번호. 리소스 이름 접두어로 사용 (예: `sk199-...`) |
| `global.namespace` | `"skala-practice"` | 배포할 Kubernetes 네임스페이스 |
| `global.appImageRegistry` | `"amdp-registry.skala-ai.com/skala25a"` | 컨테이너 이미지 레지스트리 (`imageRegistry` 미사용 — Bitnami 충돌 방지) |
| `springboot.ingress.baseDomain` | `"skala25a.project.skala-ai.com"` | Ingress 도메인 기반 (`sk<번호>-ingress.<baseDomain>`) |
| `mariadb.enabled` | `true` | false 시 MariaDB 배포 제외 |

## 생성되는 리소스 (userName=199 기준)

| 서비스 | 리소스 | 이름 |
|--------|--------|------|
| Spring Boot | Deployment, Service, Ingress | `sk199-myfirst-api-server` |
| Vue.js | Deployment, Service | `sk199-myfirst-frontend` |
| Python | Deployment, Service | `sk199-my-app-python` |
| MariaDB | StatefulSet, Service (Bitnami) | `<release>-mariadb` |

## 사용 방법

### 1. MariaDB 의존성 다운로드 (최초 1회)

```bash
cd 01.umbrella-chart
helm dependency update
```

### 2. 설치

```bash
# 기본 설치 (userName=199)
helm upgrade --install myfirst-helm ./01.umbrella-chart \
  --namespace skala-practice \
  --create-namespace

# userName 변경 (예: 200)
helm upgrade --install myfirst-helm ./01.umbrella-chart \
  --namespace skala-practice \
  --set global.userName=200

# 여러 값 오버라이드
helm upgrade --install myfirst-helm ./01.umbrella-chart \
  --namespace skala-practice \
  --set global.userName=200 \
  --set springboot.replicaCount=2 \
  --set mariadb.enabled=false
```

### 3. 렌더링 확인 (dry-run, 클러스터 미적용)

```bash
helm template myfirst-helm ./01.umbrella-chart --set global.userName=199
```

### 4. 배포 후 안내 메시지 확인

```bash
helm get notes myfirst-helm -n skala-practice
```

### 5. 삭제

```bash
helm uninstall myfirst-helm --namespace skala-practice
```

## 주의사항

- `global.appImageRegistry` 를 사용합니다. `global.imageRegistry` 로 설정하면 Bitnami MariaDB 이미지 경로에도 전파되어 `Init:ImagePullBackOff` 오류가 발생합니다.
- MariaDB에는 Debezium CDC를 위한 Binlog 설정(`server-id`, `binlog-format=ROW` 등)이 포함되어 있습니다.
- `helm dependency update` 없이 설치하면 MariaDB 차트를 찾지 못해 실패합니다.


## 서브차트별 설정 오버라이드

`values.yaml`에서 각 서비스 섹션을 수정하거나 `--set` 플래그로 재정의할 수 있습니다.

```yaml
# values.yaml 예시
global:
  userName: "200"       # ← 이 값만 바꾸면 모든 리소스 이름이 sk200-... 으로 변경됨

springboot:
  replicaCount: 2
  spring:
    profilesActive: "prod"

mariadb:
  enabled: false        # MariaDB 배포 제외
```
