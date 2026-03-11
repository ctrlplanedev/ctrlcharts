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

{{- define "ctrlplane.authSecretEnvVars" -}}
{{- $authSecret := .Values.global.secrets.authSecret -}}
{{- if not (include "ctrlplane.isValueFrom" $authSecret) -}}
{{- $secretName := (printf "%s-auth-secret" .Release.Name) -}}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_SECRET" "value" (dict "valueFrom" (dict "secretKeyRef" (dict "name" $secretName "key" "AUTH_SECRET")))) }}
{{- else }}
{{ include "ctrlplane.envVar" (dict "name" "AUTH_SECRET" "value" $authSecret) }}
{{- end -}}
{{- end -}}

{{- define "ctrlplane.encryptionKeyEnvVars" -}}
{{- $encryptionKey := .Values.global.secrets.encryptionKey -}}
{{- if not (include "ctrlplane.isValueFrom" $encryptionKey) -}}
{{- $secretName := (printf "%s-encryption-key" .Release.Name) -}}
{{ include "ctrlplane.envVar" (dict "name" "VARIABLES_AES_256_KEY" "value" (dict "valueFrom" (dict "secretKeyRef" (dict "name" $secretName "key" "AES_256_KEY")))) }}
{{- else }}
{{ include "ctrlplane.envVar" (dict "name" "VARIABLES_AES_256_KEY" "value" $encryptionKey) }}
{{- end -}}
{{- end -}}

{{/*
Generate all auth provider environment variables
*/}}
{{- define "ctrlplane.authProviderEnvVars" -}}
{{ include "ctrlplane.googleAuthEnvVars" . }}
{{ include "ctrlplane.oktaAuthEnvVars" . }}
{{ include "ctrlplane.authSecretEnvVars" . }}
{{ include "ctrlplane.encryptionKeyEnvVars" . }}
{{- end -}}
