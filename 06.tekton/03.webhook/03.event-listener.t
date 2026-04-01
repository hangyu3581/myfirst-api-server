apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: ${USER_NAME}-springboot-listener
  namespace: skala-tekton
spec:
  serviceAccountName: ${USER_NAME}-pipeline-sa
  triggers:
    - name: ${USER_NAME}-springboot-trigger
      interceptors:
        - name: "github-filter"
          ref:
            name: "cel"
          params:
          - name: "filter"
            value: "body.ref == 'refs/heads/master' || body.ref == 'refs/heads/main'"
          - name: "filter"
            value: "body.ref != 'refs/heads/gitops'"
      bindings:
        - ref: ${USER_NAME}-springboot-binding
      template:
        ref: ${USER_NAME}-springboot-trigger-template

