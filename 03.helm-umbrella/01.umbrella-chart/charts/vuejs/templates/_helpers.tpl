{{/*
사용자 접두어 생성 (예: sk199)
*/}}
{{- define "vuejs.userPrefix" -}}
{{- printf "sk%v" .Values.global.userName -}}
{{- end }}

{{/*
앱 이름 (예: sk199-myfirst-frontend)
*/}}
{{- define "vuejs.appName" -}}
{{- printf "%s-myfirst-frontend" (include "vuejs.userPrefix" .) -}}
{{- end }}

{{/*
컨테이너 이미지 전체 경로
*/}}
{{- define "vuejs.image" -}}
{{- printf "%s/%v-myfirst-frontend:%s" .Values.global.appImageRegistry (include "vuejs.userPrefix" .) .Values.image.tag -}}
{{- end }}
