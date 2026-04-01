apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: ${USER_NAME}-hello-task-run
  namespace: skala-tekton
spec:
  taskRef:
    name: hello
