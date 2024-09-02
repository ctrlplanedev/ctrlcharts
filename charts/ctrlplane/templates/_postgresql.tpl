{{- define "ctrlplane.postgresqlUrl" -}}
{{- printf "postgresql://%s:%s@%s:%d/%s" .Values.global.postgresql.user .Values.global.postgresql.password .Values.global.postgresql.host .Values.global.postgresql.port .Values.global.postgresql.database   -}}
{{- end -}}