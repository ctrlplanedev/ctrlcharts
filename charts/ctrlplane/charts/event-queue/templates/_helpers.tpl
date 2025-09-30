{{/*
Expand the name of the chart.
*/}}
{{- define "event-queue.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "event-queue.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "event-queue.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "event-queue.labels" -}}
helm.sh/chart: {{ include "event-queue.chart" . }}
{{ include "event-queue.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "event-queue.selectorLabels" -}}
app.kubernetes.io/name: {{ include "event-queue.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "event-queue.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "event-queue.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{ define "pgbouncer.ini" }}

{{/* [databases] section */}}
{{- if $.Values.databases }}
  {{ printf "[databases]" }}
  {{- range $key, $value := .Values.databases }}
    {{ $key }} ={{ range $k, $v := $value }} {{ $k }}={{ $v }}{{ end }}
  {{- end }}
{{- end }}

{{/* [pgbouncer] section */}}
{{- if $.Values.pgbouncer }}
  {{ printf "[pgbouncer]" }}
  {{- range $k, $v := $.Values.pgbouncer }}
    {{ $k }} = {{ $v }}
  {{- end }}
{{- end }}

{{/* [users] section */}}
{{- if $.Values.users }}
  {{ printf "[users]" }}
  {{- range $k, $v := $.Values.users }}
    {{ $k }} = {{ $v }}
  {{- end }}
{{- end }}

{{/* include is a special configuration within [pgbouncer] section */}}
{{- if $.Values.include }}
  {{ printf "%s %s" "%include" $.Values.include }}
{{- end }}

{{ end }}
