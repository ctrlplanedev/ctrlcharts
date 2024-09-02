{{/* 
  Github bot configuration
*/}}
{{- define "ctrlplane.githubBot" -}}
{{- if .Values.global.integrations.github.bot}}
name: {{ .Values.global.integrations.github.bot.name }}
clientId: {{ .Values.global.integrations.github.bot.clientId }}
appId: {{ .Values.global.integrations.github.bot.appId }}
secretRef: {{ .Release.Name }}-connections
{{- end -}}
{{- end -}}

{{/*
  Github url configuration
*/}}
{{- define "ctrlplane.githubUrl" -}}
{{- .Values.global.integrations.github.url -}}
{{- end -}}