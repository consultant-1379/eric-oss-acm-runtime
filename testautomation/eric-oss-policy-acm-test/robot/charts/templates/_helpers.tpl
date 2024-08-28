{{/*
Expand the name of the chart.
*/}}
{{- define "charts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "eric-oss-csit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "eric-oss-csit.namespace" -}}
  {{- default .Release.Namespace .Values.nsPrefix -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "charts.fullname" -}}
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
{{- define "charts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "charts.labels" -}}
helm.sh/chart: {{ include "charts.chart" . }}
{{ include "charts.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "charts.selectorLabels" -}}
app.kubernetes.io/name: {{ include "charts.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/type: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "charts.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "charts.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create env for test job
*/}}
{{- define "eric-oss-csit-test.containerEnv" -}}
{{- $dot := default . .dot -}}
{{- $ContainersEnv := .ContainersEnv -}}
{{- $ContainersSecret := .ContainersSecret -}}
{{- if $dot.Values.container -}}
    {{- if $dot.Values.container.env -}}
    {{- $ContainersEnv := $dot.Values.container.env -}}
    {{- range $name, $value := $ContainersEnv }}
          - name: {{ $name }}
            {{ $value| toYaml }}
    {{- end -}}
    {{- end -}}
{{- end -}}
{{- end }}

{{/*
Create storageCalss for pvc
*/}}
{{- define "eric-oss-csit-test.storageClass" -}}
{{- $dot := default . .dot -}}
{{- $storageClassName := .storageClassName -}}
    {{- if $dot.Values.persistent -}}
        {{- if $dot.Values.persistent.storageClassOverride -}}
        {{- $storageClassName = $dot.Values.persistent.storageClassOverride -}}
        {{- end -}}
    {{- end -}}
    {{- printf "%s" $storageClassName -}}
{{- end }}

{{/*
The csitTestImage path
*/}}
{{- define "eric-oss-csit.csitTestImagePath" }}
{{- $dot := default . .dot -}}
    {{- $registryUrl := .registryUrl -}}
    {{- $repoPath := .repoPath -}}
    {{- $name := .name -}}
    {{- $tag := .tag -}}
    {{- if $dot.Values.imageCredentials -}}
        {{- if $dot.Values.imageCredentials.csitTestImage -}}
            {{- if $dot.Values.imageCredentials.csitTestImage.registry -}}
                {{- if $dot.Values.imageCredentials.csitTestImage.registry.url -}}
                    {{- $registryUrl = $dot.Values.imageCredentials.csitTestImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.csitTestImage.repoPath -}}
                {{- $repoPath = $dot.Values.imageCredentials.csitTestImage.repoPath -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.csitTestImage.name -}}
                {{- $name = $dot.Values.imageCredentials.csitTestImage.name -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.csitTestImage.tag -}}
                {{- $tag = $dot.Values.imageCredentials.csitTestImage.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- printf "%s/%s/%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The busybox path
*/}}
{{- define "eric-oss-csit.busyboxImagePath" }}
{{- $dot := default . .dot -}}
    {{- $registryUrl := .registryUrl -}}
    {{- $repoPath := .repoPath -}}
    {{- $name := .name -}}
    {{- $tag := .tag -}}
    {{- if $dot.Values.imageCredentials -}}
        {{- if $dot.Values.imageCredentials.busyboxImage -}}
            {{- if $dot.Values.imageCredentials.busyboxImage.registry -}}
                {{- if $dot.Values.imageCredentials.busyboxImage.registry.url -}}
                    {{- $registryUrl = $dot.Values.imageCredentials.busyboxImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.busyboxImage.repoPath -}}
                {{- $repoPath = $dot.Values.imageCredentials.busyboxImage.repoPath -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.busyboxImage.name -}}
                {{- $name = $dot.Values.imageCredentials.busyboxImage.name -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.busyboxImage.tag -}}
                {{- $tag = $dot.Values.imageCredentials.busyboxImage.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- printf "%s/%s/%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}


{{/*
The readinessImage path
*/}}
{{- define "eric-oss-csit.readinessImagePath" }}
{{- $dot := default . .dot -}}
    {{- $registryUrl := .registryUrl -}}
    {{- $repoPath := .repoPath -}}
    {{- $name := .name -}}
    {{- $tag := .tag -}}
    {{- if $dot.Values.imageCredentials -}}
        {{- if $dot.Values.imageCredentials.readinessImage -}}
            {{- if $dot.Values.imageCredentials.readinessImage.registry -}}
                {{- if $dot.Values.imageCredentials.readinessImage.registry.url -}}
                    {{- $registryUrl = $dot.Values.imageCredentials.readinessImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.readinessImage.repoPath -}}
                {{- $repoPath = $dot.Values.imageCredentials.readinessImage.repoPath -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.readinessImage.name -}}
                {{- $name = $dot.Values.imageCredentials.readinessImage.name -}}
            {{- end -}}
            {{- if $dot.Values.imageCredentials.readinessImage.tag -}}
                {{- $tag = $dot.Values.imageCredentials.readinessImage.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- printf "%s/%s/%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Creats password env
*/}}
{{- define "eric-oss-pf-acm-runtime.passwordEnv"}}
{{- $dot := default . .dot -}}
{{- range $key, $val := $dot.Values.config }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: app-env-secret
      key: {{ $key }}
{{- end }}
{{- end }}

{{/*
Creats password env
*/}}
{{- define "eric-oss-pf-acm-runtime.appUserPassword" -}}
{{- $dot := default . .dot -}}
{{- $appUserPassword := .appUserPassword -}}
    {{- if .Values.config.appUserPassword -}}
    {{- $appUserPassword := $dot.Values.config.appUserPassword -}}
    {{- end -}}
    {{- printf "%s" $appUserPassword -}}
{{- end }}
