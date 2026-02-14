{{- define "ctrlc-sync.envs" -}}
{{- if kindIs "map" .Values.ctrlc.apiKey -}}
- name: CTRLPLANE_API_KEY
{{- toYaml .Values.ctrlc.apiKey | nindent 2 }}
{{- else -}}
- name: CTRLPLANE_API_KEY
  valueFrom:
    secretKeyRef:
      name: "{{ include "ctrlc-sync.secretname" . }}"
      key: "apiKey"
{{- end }}

{{- if kindIs "map" .Values.ctrlc.workspaceID }}
- name: CTRLPLANE_WORKSPACE
{{- toYaml .Values.ctrlc.workspaceID | nindent 2 }}
{{- else }}
- name: CTRLPLANE_WORKSPACE
  value: "{{ .Values.ctrlc.workspaceID }}"
{{- end }}

{{- if kindIs "map" .Values.ctrlc.apiURL }}
- name: CTRLPLANE_URL
{{- toYaml .Values.ctrlc.apiURL | nindent 2 }}
{{- else }}
- name: CTRLPLANE_URL
  value: "{{ .Values.ctrlc.apiURL }}"
{{- end }}

{{- if kindIs "map" .Values.ctrlc.identifier }}
- name: CTRLPLANE_CLUSTER_IDENTIFIER
{{- toYaml .Values.ctrlc.identifier | nindent 2 }}
{{- else }}
- name: CTRLPLANE_CLUSTER_IDENTIFIER
  value: "{{ .Values.ctrlc.identifier }}"
{{- end }}

{{- if kindIs "map" .Values.ctrlc.logLevel }}
- name: CTRLPLANE_LOG_LEVEL
{{- toYaml .Values.ctrlc.logLevel | nindent 2 }}
{{- else }}
- name: CTRLPLANE_LOG_LEVEL
  value: "{{ .Values.ctrlc.logLevel }}"
{{- end }}

{{- end }}

