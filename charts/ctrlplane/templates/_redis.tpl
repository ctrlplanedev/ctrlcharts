{{- define "ctrlplane.redisUrl" -}}
{{- printf "postgresql://:%s@%s:%d" .Values.global.redis.password .Values.global.redis.host .Values.global.redis.porte   -}}
{{- end -}}