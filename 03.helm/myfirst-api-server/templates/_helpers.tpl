{{/*
리소스 이름: {{ userName }}-{{ chartName }}
예) sk199-myfirst-api-server
*/}}
{{- define "myfirst-api-server.fullname" -}}
{{- printf "%s-%s" .Values.userName .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
공통 레이블 (모든 리소스에 붙는 레이블)
*/}}
{{- define "myfirst-api-server.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
셀렉터 레이블 (Deployment ↔ Service 연결에 사용)
*/}}
{{- define "myfirst-api-server.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
