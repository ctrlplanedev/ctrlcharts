{{/*
  Github url configuration
*/}}
{{- define "ctrlplane.githubUrl" -}}
{{- .Values.global.integrations.github.url -}}
{{- end -}}

{{/*
Generate GitHub bot environment variables using the new valueFrom pattern
*/}}
{{- define "ctrlplane.githubBotEnvVars" -}}
{{- $bot := .Values.global.integrations.github.bot -}}
{{- if $bot.name }}
- name: GITHUB_BOT_NAME
  value: {{ $bot.name | quote }}
{{- end }}
{{- include "ctrlplane.envVar" (dict "name" "GITHUB_BOT_CLIENT_ID" "value" $bot.clientId) }}
{{- include "ctrlplane.envVar" (dict "name" "GITHUB_BOT_APP_ID" "value" $bot.appId) }}
{{- include "ctrlplane.envVar" (dict "name" "GITHUB_BOT_CLIENT_SECRET" "value" $bot.clientSecret) }}
{{- include "ctrlplane.envVar" (dict "name" "GITHUB_BOT_PRIVATE_KEY" "value" $bot.privateKey) }}
{{- include "ctrlplane.envVar" (dict "name" "GITHUB_WEBHOOK_SECRET" "value" $bot.webhookSecret) }}
{{- end -}}