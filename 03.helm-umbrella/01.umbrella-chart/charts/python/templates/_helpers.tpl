{{/*
사용자 접두어 생성 (예: sk199)
*/}}
{{- define "python.userPrefix" -}}
{{- printf "sk%v" .Values.global.userName -}}
{{- end }}

{{/*
앱 이름 (예: sk199-my-app-python)
*/}}
{{- define "python.appName" -}}
{{- printf "%s-my-app-python" (include "python.userPrefix" .) -}}
{{- end }}

{{/*
컨테이너 이미지 전체 경로
*/}}
{{- define "python.image" -}}
{{- printf "%s/%v-my-app-python:%s" .Values.global.appImageRegistry (include "python.userPrefix" .) .Values.image.tag -}}
{{- end }}
