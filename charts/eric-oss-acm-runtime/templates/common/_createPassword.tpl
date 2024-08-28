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
  Resolve the master password to be used to derive other passwords. The value of
  .Values.masterPassword is used by default, unless either override mechanism is
  used:

  - .Values.global.masterPassword  : override default master password for all charts
  - .Values.masterPasswordOverride : override global and default masterPassword on a per chart basis
*/}}
{{- define "eric-oss-acm-runtime.masterPassword" -}}
  {{ if .Values.masterPasswordOverride }}
    {{- printf "%s" .Values.masterPasswordOverride -}}
  {{ else if .Values.global.masterPassword }}
    {{- printf "%s" .Values.global.masterPassword -}}
  {{ else if .Values.masterPassword }}
    {{- printf "%s" .Values.masterPassword -}}
  {{ else if eq "testRelease" (include "eric-oss-acm-runtime.release" .) }}
    {{/* Special case for chart liniting. DON"T NAME YOUR PRODUCTION RELEASE testRelease */}}
    {{- printf "testRelease" -}}
  {{ else if eq "test-release" .Release.Name }}
    {{/* Special case for chart linting in helm3. DON"T NAME YOUR PRODUCTION RELEASE test-release */}}
    {{- printf "testRelease" -}}
  {{ else }}
    {{ fail "masterPassword not provided" }}
  {{ end }}
{{- end -}}

{{- define "eric-oss-acm-runtime._defaultPasswordStrength" -}}
  {{ if .Values.passwordStrengthOverride }}
    {{- printf "%s" .Values.passwordStrengthOverride -}}
  {{ else if .Values.global.passwordStrength }}
    {{- printf "%s" .Values.global.passwordStrength -}}
  {{ else if .Values.passwordStrength }}
    {{- printf "%s" .Values.passwordStrength -}}
  {{ else }}
    {{- printf "long" }}
  {{ end }}
{{- end -}}

{{/*
  Generate a new password based on masterPassword. The new password is not
  random, it is derived from masterPassword, fully qualified chart name and
  additional uid provided by the user. This ensures that every time when we
  run this function from the same place, with the same password and uid we
  get the same results. This allows to avoid password changes while you are
  doing upgrade.

  The function can take from one to three arguments (inside a dictionary):
  - .dot : environment (.)
  - .uid : unique identifier of password to be generated within this particular chart. Use only when you create more than a single password within one chart
  - .strength : complexity of derived password. See derivePassword documentation for more details

  Example calls:

    {{ include "eric-oss-acm-runtime.createPassword" . }}
    {{ include "eric-oss-acm-runtime.createPassword" (dict "dot" . "uid" "mysqlRootPasswd") }}

*/}}
{{- define "eric-oss-acm-runtime.createPassword" -}}
  {{- $dot := default . .dot -}}
  {{- $uid := default "onap" .uid -}}
  {{- $defaultStrength := include "eric-oss-acm-runtime._defaultPasswordStrength" $dot | trim -}}
  {{- $strength := default $defaultStrength .strength -}}
  {{- $mp := include "eric-oss-acm-runtime.masterPassword" $dot -}}
  {{- derivePassword 1 $strength $mp (include "eric-oss-acm-runtime.fullname" $dot) $uid -}}
{{- end -}}
