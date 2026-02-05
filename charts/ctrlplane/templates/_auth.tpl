{{/*
Generate Google OAuth environment variables using the new valueFrom pattern
*/}}
{{- define "ctrlplane.googleAuthEnvVars" -}}
{{- $google := .Values.global.authProviders.google -}}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_GOOGLE_CLIENT_ID" "value" $google.clientId) }}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_GOOGLE_CLIENT_SECRET" "value" $google.clientSecret) }}
{{- end -}}

{{/*
Generate Okta OAuth environment variables using the new valueFrom pattern
*/}}
{{- define "ctrlplane.oktaAuthEnvVars" -}}
{{- $okta := .Values.global.authProviders.okta -}}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_OKTA_ISSUER" "value" $okta.issuer) }}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_OKTA_CLIENT_ID" "value" $okta.clientId) }}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_OKTA_CLIENT_SECRET" "value" $okta.clientSecret) }}
{{- end -}}

{{/*
Generate all auth provider environment variables
*/}}
{{- define "ctrlplane.authProviderEnvVars" -}}
{{ include "ctrlplane.googleAuthEnvVars" . }}
{{ include "ctrlplane.oktaAuthEnvVars" . }}
{{- end -}}