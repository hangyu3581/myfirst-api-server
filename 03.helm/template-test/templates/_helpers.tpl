{{- define "mychart.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end }}

