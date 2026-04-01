FROM amdp-registry.skala-ai.com/skala25a/my-ai-base:1.0.0

# lifecycle (prob, healthz, metrics) 테스트를 위한 코드 추가
COPY fastserver.py fastserver.py

CMD ["python3", "fastserver.py"]
