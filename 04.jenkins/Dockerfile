# JDK17 소스 이미지 (멀티스테이지 빌드용)
FROM eclipse-temurin:17-jdk AS jdk17

FROM jenkins/jenkins:lts-jdk21

USER root

# ──────────────────────────────────────────────
# 1. 기본 유틸리티 설치
# ──────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      git \
      python3 \
      python3-pip \
      wget \
      unzip \
      jq \
      sudo \
      maven && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────
# 2. Buildah (rootless 컨테이너 빌드) 설치
#    - multi-user 가 동시에 이미지 빌드해도 충돌 없도록
#      각 사용자(k8s Pod) 별 격리 환경에서 실행
# ──────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      buildah \
      uidmap \
      fuse-overlayfs \
      slirp4netns \
      containernetworking-plugins \
      netavark \
      aardvark-dns && \
    rm -rf /var/lib/apt/lists/*

# subuid / subgid 매핑 (rootless 모드)
RUN grep -q "^jenkins:" /etc/subuid || echo "jenkins:100000:65536" >> /etc/subuid && \
    grep -q "^jenkins:" /etc/subgid || echo "jenkins:100000:65536" >> /etc/subgid

# ──────────────────────────────────────────────
# 3. Container Storage 설정 (VFS 드라이버)
#    - k8s pod 내부에서 overlay 사용 시 권한 문제 방지
# ──────────────────────────────────────────────
RUN mkdir -p /etc/containers /var/lib/containers/storage /var/run/containers/storage && \
    printf '[storage]\n\
driver = "vfs"\n\
runroot = "/var/run/containers/storage"\n\
graphroot = "/var/lib/containers/storage"\n' > /etc/containers/storage.conf && \
    printf 'unqualified-search-registries = ["docker.io","quay.io","registry.fedoraproject.org"]\n' \
      > /etc/containers/registries.conf && \
    printf '[engine]\ncni_plugin_dirs = ["/usr/lib/cni"]\nhelper_binaries_dir = ["/usr/lib/netavark","/usr/libexec/podman","/usr/lib/podman"]\n' \
      > /etc/containers/containers.conf && \
    chown -R jenkins:jenkins /var/lib/containers /var/run/containers

# newuidmap / newgidmap setuid 설정 (rootless user namespace warning 제거)
RUN chmod u+s /usr/bin/newuidmap /usr/bin/newgidmap

ENV BUILDAH_ISOLATION=chroot
ENV STORAGE_DRIVER=vfs
ENV XDG_RUNTIME_DIR=/tmp/run/user/1000
# buildah이 containers.conf / registries.conf를 명시적으로 참조하도록 설정
ENV CONTAINERS_CONF=/etc/containers/containers.conf
ENV CONTAINERS_REGISTRIES_CONF=/etc/containers/registries.conf
RUN mkdir -p /tmp/run/user/1000 && chown -R jenkins:jenkins /tmp/run/user/1000

# ──────────────────────────────────────────────
# 4. kubectl 설치
# ──────────────────────────────────────────────
RUN ARCH=$(dpkg --print-architecture) && \
    K8S_VER=$(curl -Ls https://dl.k8s.io/release/stable.txt) && \
    curl -LO "https://dl.k8s.io/release/${K8S_VER}/bin/linux/${ARCH}/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    kubectl version --client

# ──────────────────────────────────────────────
# 5. Docker CLI 설치 (도커 소켓 마운트 빌드용)
#    Docker 공식 apt 레포는 bookworm 까지 지원 → 코드명 고정
# ──────────────────────────────────────────────
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    ARCH=$(dpkg --print-architecture) && \
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian bookworm stable" \
      > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────
# 6. sudo 설정 (jenkins 유저 → buildah 등 실행)
# ──────────────────────────────────────────────
RUN groupadd -f docker && usermod -aG docker jenkins && \
    'Defaults:jenkins !requiretty' > /etc/sudoers.d/jenkins; true && \
    echo 'Defaults:jenkins !requiretty' > /etc/sudoers.d/jenkins && \
    echo 'Defaults env_keep += "BUILDAH_ISOLATION STORAGE_DRIVER XDG_RUNTIME_DIR CONTAINERS_CONF CONTAINERS_REGISTRIES_CONF HTTP_PROXY HTTPS_PROXY NO_PROXY"' \
      >> /etc/sudoers.d/jenkins && \
    echo 'jenkins ALL=(ALL) NOPASSWD: /usr/bin/buildah, /bin/mkdir, /usr/bin/tee, /usr/bin/install, /bin/cp' \
      >> /etc/sudoers.d/jenkins && \
    chmod 0440 /etc/sudoers.d/jenkins && \
    visudo -cf /etc/sudoers

# ──────────────────────────────────────────────
# 7. GitHub CLI 설치
# ──────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
      gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# ──────────────────────────────────────────────
# 8. Maven / Gradle 환경 변수
#    base 이미지(lts-jdk17 = Eclipse Temurin)의 JAVA_HOME: /opt/java/openjdk
# ──────────────────────────────────────────────
RUN echo "export MAVEN_HOME=/usr/share/maven" > /etc/profile.d/maven.sh && \
    echo 'export JAVA_HOME=/opt/java/openjdk' > /etc/profile.d/java.sh && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile.d/java.sh

ENV GRADLE_VERSION=8.5
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -q -d /opt /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

ENV GRADLE_HOME=/opt/gradle
ENV PATH=$PATH:$GRADLE_HOME/bin

# ──────────────────────────────────────────────
# 9. JDK17 추가 (eclipse-temurin:17-jdk 이미지에서 복사)
#    베이스 이미지(lts-jdk21)의 JDK21: /opt/java/openjdk
#    JDK17 → /opt/java/jdk-17  (두 버전 동시 지원)
# ──────────────────────────────────────────────
COPY --from=jdk17 /opt/java/openjdk /opt/java/jdk-17

ENV JAVA17_HOME=/opt/java/jdk-17
ENV JAVA21_HOME=/opt/java/openjdk

# ──────────────────────────────────────────────
# 10. Jenkins 유저로 전환 후 플러그인 설치
#    multi-user 지원 핵심 플러그인 포함:
#      - kubernetes        : 동적 Pod 에이전트 (빌드 격리)
#      - role-strategy     : 사용자별 폴더 권한 제어
#      - cloudbees-folder  : 사용자별 폴더 생성
#      - job-dsl           : JCasC 에서 폴더 자동 생성
#      - authorize-project : 프로젝트 소유자 권한으로 빌드 실행
# ──────────────────────────────────────────────

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/jenkins.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli \
      --plugin-download-directory /usr/share/jenkins/ref/plugins \
      --plugin-file /usr/share/jenkins/ref/plugins.txt \
      --latest \
      --verbose

EXPOSE 8080
EXPOSE 50000

# kubeconfig (클러스터 내 In-Cluster 인증 사용 시 불필요하나 외부 접근용 유지)
COPY kube-config /usr/share/jenkins/ref/kube-config
ENV KUBECONFIG=/usr/share/jenkins/ref/kube-config
ENV COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log
