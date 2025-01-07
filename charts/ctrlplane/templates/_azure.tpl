{{/*
  Azure app configuration
*/}}
{{- define "ctrlplane.azureApp" -}}
{{- if .Values.global.integrations.azure }}
clientId: {{ .Values.global.integrations.azure.appClientId }}
secretRef: {{ .Release.Name }}-connections
{{- end -}}
{{- end -}}
