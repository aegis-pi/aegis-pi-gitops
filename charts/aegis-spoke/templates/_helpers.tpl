{{- define "aegis-spoke.name" -}}
{{- default .Chart.Name .Values.smokeApp.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "aegis-spoke.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "aegis-spoke.labels" -}}
helm.sh/chart: {{ include "aegis-spoke.chart" . }}
app.kubernetes.io/name: {{ include "aegis-spoke.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
aegis.factory/id: {{ .Values.factory.id | quote }}
aegis.factory/environment-type: {{ .Values.factory.environmentType | quote }}
aegis.factory/input-module-type: {{ .Values.factory.inputModuleType | quote }}
aegis.factory/sync-profile: {{ .Values.factory.syncProfile | quote }}
{{- end -}}

{{- define "aegis-spoke.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aegis-spoke.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
