{{- define "ctrlplane.redisUrl" -}}
{{- printf "redis://:%s@%s:%s" .Values.global.redis.password .Values.global.redis.host .Values.global.redis.port   -}}
{{- end -}}