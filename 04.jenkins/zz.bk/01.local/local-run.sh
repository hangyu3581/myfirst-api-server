#!/bin/bash

set -eux

IMAGE_NAME="custom-jenkins"
#IMAGE_NAME="custom-jenkins-buildah"
VERSION="1.1"

# 첫 번째 인자로 CPU 플랫폼 설정
if [ "${1:-}" = "arm64" ]; then
  CPU_PLATFORM=arm64
else
  CPU_PLATFORM=amd64
fi

#  amdp-registry.skala-ai.com/skala25a/skala-custom-jenkins-${CPU_PLATFORM}:1.0
docker run -d \
  --name skala-custom-jenkins \
  -p 8888:8080 \
  -p 50000:50000 \
  -v $(pwd)/jenkins_home:/var/jenkins_home \
  -v $(pwd)/jenkins.yaml:/var/jenkins_config/jenkins.yaml \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e CASC_JENKINS_CONFIG=/var/jenkins_config/jenkins.yaml \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  --group-add 0 \
  --privileged \
  ${IMAGE_NAME}-${CPU_PLATFORM}:${VERSION}
