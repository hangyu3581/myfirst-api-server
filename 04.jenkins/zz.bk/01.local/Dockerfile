#FROM jenkins/jenkins:lts
FROM jenkins/jenkins:lts-jdk17

USER root

# 기본 유틸 설치
#      openjdk-17-jdk \
#      software-properties-common \
RUN apt-get update && \
    apt-get install -y \
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
      maven && \
    rm -rf /var/lib/apt/lists/*

# buildah(루트 실행 전제) + 필요 패키지
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      buildah \
      uidmap \
      fuse-overlayfs \
      slirp4netns && \
    rm -rf /var/lib/apt/lists/*

# (선택) subuid/subgid 매핑 – 루트 모드에선 필수는 아니지만 유지 무방
RUN grep -q "^jenkins:" /etc/subuid || echo "jenkins:100000:65536" >> /etc/subuid && \
    grep -q "^jenkins:" /etc/subgid || echo "jenkins:100000:65536" >> /etc/subgid

# 전역 storage.conf: vfs + 전역 경로 사용 (루트 빌드 안정)
RUN mkdir -p /etc/containers && \
    printf '[storage]\n\
driver = "vfs"\n\
runroot = "/var/run/containers/storage"\n\
graphroot = "/var/lib/containers/storage"\n' > /etc/containers/storage.conf

# 루트 모드 빌드에 필요한 기본 환경 (sudo -E 로 전달)
ENV BUILDAH_ISOLATION=chroot
ENV STORAGE_DRIVER=vfs
ENV XDG_RUNTIME_DIR=/tmp/run/user/1000
RUN mkdir -p /tmp/run/user/1000 && chown -R jenkins:jenkins /tmp/run/user/1000

# kubectl 설치
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && kubectl version --client

# Docker CLI (필요 시)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    bash -lc 'ARCH=$(dpkg --print-architecture); \
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list' && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Dockerfile에 sudo 설치 추가
RUN apt-get update && apt-get install -y sudo && \
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# docker 그룹/권한 (필요 시)
RUN groupadd -f docker && usermod -aG docker jenkins

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Maven/Java/Gradle 환경
RUN mvn --version && echo "export MAVEN_HOME=/usr/share/maven" > /etc/profile.d/maven.sh
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture)" > /etc/profile.d/java.sh && \
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java.sh

ENV GRADLE_VERSION=8.5
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -d /opt /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$PATH:$GRADLE_HOME/bin

# SUDO NOPASSWORD
RUN set -eux; \
    echo 'Defaults:jenkins !requiretty' > /etc/sudoers.d/jenkins; \
    echo 'Defaults env_keep += "BUILDAH_ISOLATION STORAGE_DRIVER XDG_RUNTIME_DIR HTTP_PROXY HTTPS_PROXY NO_PROXY"' >> /etc/sudoers.d/jenkins; \
    echo 'jenkins ALL=(ALL) NOPASSWD: /usr/bin/buildah, /bin/mkdir, /usr/bin/tee, /usr/bin/install, /bin/cp' >> /etc/sudoers.d/jenkins; \
    chmod 0440 /etc/sudoers.d/jenkins; chown root:root /etc/sudoers.d/jenkins; \
    visudo -cf /etc/sudoers

# Jenkins 기본 세팅
USER jenkins
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/jenkins.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli \
    --plugin-download-directory /usr/share/jenkins/ref/plugins \
    --plugin-file /usr/share/jenkins/ref/plugins.txt \
    --latest \
    --verbose
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080
EXPOSE 50000

# kubeconfig
COPY --chown=1000:1000 kube-config /usr/share/jenkins/ref/kube-config
ENV COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log
ENV KUBECONFIG=/usr/share/jenkins/ref/kube-config
