{{/*{{/*

Expand the name of the chart.Expand the name of the chart.

*/}}*/}}

{{- define "todo-app.name" -}}{{- define "todo-app.name" -}}

{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}

{{- end }}{{- end }}



{{/*{{/*

Create a default fully qualified app name.Create a default fully qualified app name.

We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

If release name contains chart name it will be used as a full name.If release name contains chart name it will be used as a full name.

*/}}*/}}

{{- define "todo-app.fullname" -}}{{- define "todo-app.fullname" -}}

{{- if .Values.fullnameOverride }}{{- if .Values.fullnameOverride }}

{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}

{{- else }}{{- else }}

{{- $name := default .Chart.Name .Values.nameOverride }}{{- $name := default .Chart.Name .Values.nameOverride }}

{{- if contains $name .Release.Name }}{{- if contains $name .Release.Name }}

{{- .Release.Name | trunc 63 | trimSuffix "-" }}{{- .Release.Name | trunc 63 | trimSuffix "-" }}

{{- else }}{{- else }}

{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}

{{- end }}{{- end }}

{{- end }}{{- end }}

{{- end }}{{- end }}



{{/*{{/*

Create chart name and version as used by the chart label.Create chart name and version as used by the chart label.

*/}}*/}}

{{- define "todo-app.chart" -}}{{- define "todo-app.chart" -}}

{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}

{{- end }}{{- end }}



{{/*{{/*

Common labelsCommon labels

*/}}*/}}

{{- define "todo-app.labels" -}}{{- define "todo-app.labels" -}}

helm.sh/chart: {{ include "todo-app.chart" . }}helm.sh/chart: {{ include "todo-app.chart" . }}

{{ include "todo-app.selectorLabels" . }}{{ include "todo-app.selectorLabels" . }}

{{- if .Chart.AppVersion }}{{- if .Chart.AppVersion }}

app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}

{{- end }}{{- end }}

app.kubernetes.io/managed-by: {{ .Release.Service }}app.kubernetes.io/managed-by: {{ .Release.Service }}

{{- end }}{{- end }}



{{/*{{/*

Selector labelsSelector labels

*/}}*/}}

{{- define "todo-app.selectorLabels" -}}{{- define "todo-app.selectorLabels" -}}

app.kubernetes.io/name: {{ include "todo-app.name" . }}app.kubernetes.io/name: {{ include "todo-app.name" . }}

app.kubernetes.io/instance: {{ .Release.Name }}app.kubernetes.io/instance: {{ .Release.Name }}

{{- end }}{{- end }}



{{/*{{/*

Create the name of the service account to useCreate the name of the service account to use

*/}}*/}}

{{- define "todo-app.serviceAccountName" -}}{{- define "todo-app.serviceAccountName" -}}

{{- if .Values.serviceAccount.create }}{{- if .Values.serviceAccount.create }}

{{- default (include "todo-app.fullname" .) .Values.serviceAccount.name }}{{- default (include "todo-app.fullname" .) .Values.serviceAccount.name }}

{{- else }}{{- else }}

{{- default "default" .Values.serviceAccount.name }}{{- default "default" .Values.serviceAccount.name }}

{{- end }}{{- end }}

{{- end }}{{- end }}