{{/* 
  Github bot configuration
*/}}
{{- define "ctrlplane.githubBot" -}}
{{- if .Values.global.integrations.github.bot}}
name: {{ .Values.global.integrations.github.bot.name | quote }}
clientId: {{ .Values.global.integrations.github.bot.clientId | quote }}
appId: {{ .Values.global.integrations.github.bot.appId | quote }}
secretRef: {{ .Release.Name }}-connections
{{- end -}}
{{- end -}}

{{/*
  Github url configuration
*/}}
{{- define "ctrlplane.githubUrl" -}}
{{- .Values.global.integrations.github.url | quote -}}
{{- end -}}