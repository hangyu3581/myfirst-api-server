{{/*
사용자 접두어 생성 (예: sk199)
*/}}
{{- define "springboot.userPrefix" -}}
{{- printf "sk%v" .Values.global.userName -}}
{{- end }}

{{/*
앱 이름 (예: sk199-myfirst-api-server)
*/}}
{{- define "springboot.appName" -}}
{{- printf "%s-myfirst-api-server" (include "springboot.userPrefix" .) -}}
{{- end }}

{{/*
컨테이너 이미지 전체 경로
*/}}
{{- define "springboot.image" -}}
{{- printf "%s/%v-myfirst-api-server:%s" .Values.global.appImageRegistry (include "springboot.userPrefix" .) .Values.image.tag -}}
{{- end }}
