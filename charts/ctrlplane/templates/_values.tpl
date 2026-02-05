{{/*
Check if a value is configured as a valueFrom reference
Usage: {{ include "ctrlplane.isValueFrom" .Values.some.property }}
*/}}
{{- define "ctrlplane.isValueFrom" -}}
{{- if and (kindIs "map" .) (hasKey . "valueFrom") -}}
true
{{- end -}}
{{- end -}}

{{/*
Get the direct string value (only for direct string values)
Usage: {{ include "ctrlplane.directValue" .Values.some.property }}
*/}}
{{- define "ctrlplane.directValue" -}}
{{- if kindIs "string" . -}}
{{- . -}}
{{- else -}}
{{- fail "Value is not a string. Use ctrlplane.envVar for valueFrom references." -}}
{{- end -}}
{{- end -}}

{{/*
Generate environment variable configuration for any property
This handles both direct string values and valueFrom references
Usage: {{ include "ctrlplane.envVar" (dict "name" "ENV_VAR_NAME" "value" .Values.some.property) }}
*/}}
{{- define "ctrlplane.envVar" -}}
{{- $name := .name -}}
{{- $value := .value -}}
{{- if and (kindIs "map" $value) (hasKey $value "valueFrom") -}}
- name: {{ $name }}
  valueFrom:
    {{- toYaml (get $value "valueFrom") | nindent 4 }}
{{- else if kindIs "string" $value -}}
{{- if ne $value "" -}}
- name: {{ $name }}
  value: {{ $value | quote }}
{{- end -}}
{{- else if not (kindIs "invalid" $value) -}}
- name: {{ $name }}
  value: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Generate multiple environment variables from a map of properties
Usage: {{ include "ctrlplane.envVars" (dict "envVars" (dict "CLIENT_ID" .Values.auth.clientId "CLIENT_SECRET" .Values.auth.clientSecret)) }}
*/}}
{{- define "ctrlplane.envVars" -}}
{{- range $envName, $value := .envVars -}}
{{- include "ctrlplane.envVar" (dict "name" $envName "value" $value) }}
{{- end -}}
{{- end -}}

{{/*
Check if a value should be stored in a secret (i.e., it's a direct string value)
This is used to determine if we should create secrets for backwards compatibility
Usage: {{ include "ctrlplane.shouldStoreInSecret" .Values.some.property }}
*/}}
{{- define "ctrlplane.shouldStoreInSecret" -}}
{{- if and (kindIs "string" .) (ne . "") -}}
true
{{- end -}}
{{- end -}}

{{/*
Get value for storing in secret (base64 encoded)
Only works with direct string values
Usage: {{ include "ctrlplane.secretValue" .Values.some.property }}
*/}}
{{- define "ctrlplane.secretValue" -}}
{{- if include "ctrlplane.shouldStoreInSecret" . -}}
{{- . | b64enc -}}
{{- else -}}
{{- fail "Cannot store valueFrom reference in secret. Use environment variables instead." -}}
{{- end -}}
{{- end -}}