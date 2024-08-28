{{/*
# *******************************************************************************
# * Copyright (C) 2022 Ericsson Software Technology
# *
# * The copyright to the computer program(s) herein is the property of
# * Ericsson Software Technology. The programs may be used and/or copied
# * only with written permission from Ericsson Software Technology or in
# * accordance with the terms and conditions stipulated in the
# * agreement/contract under which the program(s) have been supplied.
# *******************************************************************************
 */}}

{{/*
  Expand the name of a chart.
  The function takes from one to two arguments (inside a dictionary):
     - .dot : environment (.)
     - .suffix : add a suffix to the name
*/}}
{{- define "eric-oss-acm-runtime.name" -}}
  {{- $dot := default . .dot -}}
  {{- $suffix := .suffix -}}
  {{- default $dot.Chart.Name $dot.Values.nameOverride | trunc 63 | trimSuffix "-" -}}{{ if $suffix }}{{ print "-" $suffix }}{{ end }}
{{- end -}}

{{/*
  The same as eric-oss-acm-runtime.full name but based on passed dictionary instead of trying to figure
  out chart name on its own.
*/}}
{{- define "eric-oss-acm-runtime.fullnameExplicit" -}}
  {{- $dot := .dot }}
  {{- $name := .chartName }}
  {{- $suffix := default "" .suffix -}}
  {{- printf "%s-%s-%s" (include "eric-oss-acm-runtime.release" $dot) $name $suffix | trunc 63 | trimSuffix "-" | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create a default fully qualified application name.
  Truncated at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  Usage:
      include "eric-oss-acm-runtime.fullname" .
      include "eric-oss-acm-runtime.fullname" (dict "suffix" "mySuffix" "dot" .)
  The function takes from one to two arguments:
     - .dot : environment (.)
     - .suffix : add a suffix to the fullname
*/}}
{{- define "eric-oss-acm-runtime.fullname" -}}
{{- $dot := default . .dot -}}
{{- $suffix := default "" .suffix -}}
  {{- $name := default $dot.Chart.Name $dot.Values.nameOverride -}}
  {{/* when linted, the name must be lower cased. When used from a component,
       name should be overriden in order to avoid collision so no need to do it */}}
  {{- if eq (printf "%s/templates" $name) $dot.Template.BasePath -}}
  {{- $name = lower $name -}}
  {{- end -}}
  {{- include "eric-oss-acm-runtime.fullnameExplicit" (dict "dot" $dot "chartName" $name "suffix" $suffix) }}
{{- end -}}

{{/*
  Retrieve the "original" release from the component release:
  if ONAP is deploy with "helm deploy --name toto", then cassandra components
  will have "toto-cassandra" as release name.
  this function would answer back "toto".
*/}}
{{- define "eric-oss-acm-runtime.release" -}}
  {{- first (regexSplit "-" .Release.Name -1)  }}
{{- end -}}

{{- define "eric-oss-acm-runtime.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
