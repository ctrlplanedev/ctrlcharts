{{- define "ctrlplane.redisUrl" -}}
{{- $baseUrl := printf "redis://:%s@%s:%s" .Values.global.redis.password .Values.global.redis.host .Values.global.redis.port -}}
{{- if .Values.redis.caCert -}}
{{- printf "%s?tls=true&caCertPath=/etc/ssl/certs/redis_ca.pem&ttlInSeconds=604800" $baseUrl -}}
{{- else -}}
{{- $baseUrl -}}
{{- end -}}

{{- define "ctrlplane.redisCaCert" -}}
{{- .Values.redis.caCert -}}
{{- end -}}