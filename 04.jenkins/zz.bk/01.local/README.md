webhook 실행 시 

https://jenkins.skala25a.project.skala-ai.com/github-webhook/ 을 등록하면 
자동으로 jenkins 호출

pipeline {
    agent any
    
    triggers {
        githubPush()  // GitHub webhook 수신 시 빌드 트리거
    }
}
