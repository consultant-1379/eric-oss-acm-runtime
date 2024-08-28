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
Renders a value that contains template.
Usage:
{{ include "eric-oss-acm-runtime.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "eric-oss-acm-runtime.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Retrieve values from the subchart, not from the main chart
Usage:
{{- $initRoot := default $dot.Values.subChartName .initRoot -}}
{{  $subchartDot := fromJson (include "eric-oss-acm-runtime.subChartDot" (dict "dot" . "initRoot" $initRoot)) }}
*/}}
{{- define "eric-oss-acm-runtime.subChartDot" }}
{{- $initRoot := .initRoot }}
{{- $dot := .dot }}
{{ mergeOverwrite (deepCopy (omit $dot "Values" "Chart")) (dict "Chart" (set (set (fromJson (toJson $dot.Chart)) "Name" $initRoot.nameOverride) "Version" $dot.Chart.Version) "Values" (mergeOverwrite (deepCopy $initRoot) (dict "global" $dot.Values.global))) | toJson }}
{{- end -}}

{{- define "eric-oss-acm-runtime.namespace" -}}
  {{- default .Release.Namespace .Values.nsPrefix -}}
{{- end -}}
