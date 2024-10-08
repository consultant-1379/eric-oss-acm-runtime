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
  For internal use only!

  Generates a secret header with given name and desired labels.

  The template takes two arguments:
    - .global: environment (.)
    - .name: name of the secret
    - .annotations: annotations which should be used

  Example call:
    {{ include "eric-oss-acm-runtime.secret._header" (dict "global" . "name" "myFancyName") }}
*/}}
{{- define "eric-oss-acm-runtime.secret._header" -}}
{{- $global := .global }}
{{- $name := .name }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ $name }}
  labels:
  {{- include "eric-oss-acm-runtime.labels" $global | nindent 4 }}
  annotations:
  {{- include "eric-oss-acm-runtime.annotations" $global | nindent 4 }}
type: Opaque
{{- end -}}

{{/*
  For internal use only!

  Pick a value based on "user input" and generation policy.

  The template takes below arguments:
    - .global: environment (.)
    - .secretName: name of the secret where the value will be placed
    - .secretEnv: map of values which configures this secret. This can contain below keys:
        - value: Value of secret key provided by user (can be a template inside a string)
        - policy: What to do if value is missing or empty. Possible options are:
            - generate: Generate a new password deriving it from master password
            - required: Fail the deployment if value has not been provided
          Defaults to generate.
        - name: Name of the key to which this value should be assigned
*/}}
{{- define "eric-oss-acm-runtime.secret._value" -}}
  {{- $global := .global }}
  {{- $name := .secretName }}
  {{- $secretEnv := .secretEnv }}
  {{- $value := tpl $secretEnv.value $global }}
  {{- $policy := default "generate" $secretEnv.policy }}

  {{- if $value }}
    {{- $value | quote }}
  {{- else if eq $policy "generate" }}
    {{- include "eric-oss-acm-runtime.createPassword" (dict "dot" $global "uid" $name) | quote }}
  {{- else }}
    {{- fail (printf "Value for %s secret %s key not provided" $name $secretEnv.name) }}
  {{- end }}
{{- end -}}

{{/*
  For internal use only!

  Pick a value based on "user input" and generation policy.

  The template takes below arguments:
    - .global: environment (.)
    - .secretName: name of the secret where the value will be placed
    - .secretEnv: map of values which configures this secret. This can contain below keys:
        - value: Value of secret key provided by user (can be a template inside a string)
        - policy: What to do if value is missing or empty. Possible options are:
            - generate: Generate a new password deriving it from master password
            - required: Fail the deployment if value has not been provided
          Defaults to generate.
        - name: Name of the key to which this value should be assigned
*/}}
{{- define "eric-oss-acm-runtime.secret._valueFast" -}}
  {{- $global := .global }}
  {{- $name := .secretName }}
  {{- $secretEnv := .secretEnv }}
  {{- $value := $secretEnv.value }}
  {{- $policy := default "generate" $secretEnv.policy }}

  {{- if $value }}
    {{- $value | quote }}
  {{- else if eq $policy "generate" }}
    {{- include "eric-oss-acm-runtime.createPassword" (dict "dot" $global "uid" $name) | quote }}
  {{- else }}
    {{- fail (printf "Value for %s secret %s key not provided" $name $secretEnv.name) }}
  {{- end }}
{{- end -}}


{{/*
  Generate a secret name based on provided name or UID.
  If UID is provided then the name is generated by appending this UID right after
  the chart name. If name is provided, it overrides the name generation algorith
  and is used right away. Both name and uid strings may contain a template to be
  resolved.

  The template takes below arguments:
    - .global: environment (.)
    - .uid: string that uniquely identifies this secret within a helm chart
    - .name: string that can be used to override default name generation algorithm
        and provide a custom name for the secret
*/}}
{{- define "eric-oss-acm-runtime.secret.genName" -}}
  {{- $global := .global }}
  {{- $uid := tpl (default "" .uid) $global }}
  {{- $name := tpl (default "" .name) $global }}
  {{- $fullname := ne (default "" .chartName) "" | ternary (include "eric-oss-acm-runtime.fullnameExplicit" (dict "dot" $global "chartName" .chartName)) (include "eric-oss-acm-runtime.fullname" $global) }}
  {{- default (printf "%s-%s" $fullname $uid) $name }}
{{- end -}}

{{- define "eric-oss-acm-runtime.secret.genNameFast" -}}
  {{- $global := .global }}
  {{- $uid := (default "" .uid) }}
  {{- $name := (default "" .name) }}
  {{- $fullname := ne (default "" .chartName) "" | ternary (include "eric-oss-acm-runtime.fullnameExplicit" (dict "dot" $global "chartName" .chartName)) (include "eric-oss-acm-runtime.name" $global) }}
  {{- if eq "test-release" $global.Release.Name -}}
  {{/* Special case for chart liniting in helm3. DON"T NAME YOUR PRODUCTION RELEASE test-release */}}
  {{- $uid = lower $uid -}}
  {{- end -}}
  {{- default (printf "%s-%s" $fullname $uid) $name }}
{{- end -}}

{{/*
  Get the real secret name by UID or name, based on the configuration provided by user.
  User may decide to not create a new secret but reuse existing one for this deployment
  (aka externalSecret). In this case the real name of secret to be used is different
  than the one declared in secret definition. This easily retrieve current secret real
  name based on declared name or UID even if it has been overrided by the user using
  externalSecret option. You should use this template always when you need to reference
  a secret created using eric-oss-acm-runtime.secret template by name.

  The template takes below arguments:
    - .global: environment (.)
    - .uid: string that uniquely identifies this secret within a helm chart
        (can be omitted if name has been provided)
    - .name: name which was used to declare a secret
        (can be omitted if uid has been provided)
*/}}
{{- define "eric-oss-acm-runtime.secret.getSecretName" -}}
  {{- $global := .global }}
  {{- $name := tpl (default "" .name) $global }}
  {{- $uid := tpl (default "" .uid) $global }}
  {{- $targetName := default (include "eric-oss-acm-runtime.secret.genName" (dict "global" $global "uid" $uid "name" .name)) $name}}
  {{- range $secret := $global.Values.secrets }}
    {{- $currUID := tpl (default "" $secret.uid) $global }}
    {{- $givenName := tpl (default "" $secret.name) $global }}
    {{- $currName := default (include "eric-oss-acm-runtime.secret.genName" (dict "global" $global "uid" $currUID "name" $secret.name)) $givenName }}
    {{- if or (eq $uid $currUID) (eq $currName $targetName) }}
      {{- $externalSecret := tpl (default "" $secret.externalSecret) $global }}
      {{- default $currName $externalSecret }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "eric-oss-acm-runtime.secret.getSecretNameFast" -}}
  {{- $global := .global }}
  {{- include "eric-oss-acm-runtime.secret.buildCache" $global }}
  {{- $secretsCache := $global.Values._secretsCache }}
  {{- $uid := tpl .uid $global }}
  {{- $secret := index $secretsCache $uid }}
  {{- $secret.realName }}
{{- end -}}

{{- define "eric-oss-acm-runtime.secret.buildCache" -}}
  {{- $global := . }}
  {{- if not $global.Values._secretsCache }}
    {{- $secretCache := dict }}
    {{- range $secret := .Values.secrets }}
      {{- $entry := dict }}
      {{- $uid := tpl (default "" $secret.uid) $global }}
      {{- $keys := keys $secret }}
      {{- range $key := (without $keys "annotations" "filePaths" "envs" )}}
        {{- $_ := set $entry $key (tpl (index $secret $key) $global) }}
      {{- end }}
      {{- if $secret.annotations }}
        {{- $_ := set $entry "annotations" $secret.annotations }}
      {{- end }}
      {{- if $secret.filePaths }}
        {{- if kindIs "string" $secret.filePaths }}
          {{- $evaluated := tpl (default "" $secret.filePaths) $global }}
          {{- if and $evaluated (ne $evaluated "\"\"") }}
            {{- $fstr := printf "val:\n%s" ($evaluated | indent 2) }}
            {{- $flist := (index (tpl $fstr $global | fromYaml) "val") }}
            {{- $_ := set $entry "filePaths" $flist }}
          {{- else }}
            {{- $_ := set $entry "filePaths" (list) }}
          {{- end }}
        {{- else }}
          {{- $_ := set $entry "filePaths" $secret.filePaths }}
        {{- end }}
      {{- end }}
      {{- if $secret.envs }}
        {{- $envsCache := (list) }}
        {{- range $env := $secret.envs }}
          {{- $tplValue := tpl (default "" $env.value) $global }}
          {{- $envsCache = append $envsCache (dict "name" $env.name "policy" $env.policy "value" $tplValue) }}
        {{- end }}
        {{- $_ := set $entry "envs" $envsCache }}
      {{- end }}
      {{- $realName := default (include "eric-oss-acm-runtime.secret.genNameFast" (dict "global" $global "uid" $uid "name" $entry.name) ) $entry.externalSecret }}
      {{- $_ := set $entry "realName" $realName }}
      {{- $_ := set $secretCache $uid $entry }}
    {{- end }}
    {{- $_ := set $global.Values "_secretsCache" $secretCache }}
  {{- end }}

{{- end -}}

{{/*
  Convenience template which can be used to easily set the value of environment variable
  to the value of a key in a secret.

  It takes care of all name mangling, usage of external secrets etc.

  The template takes below arguments:
    - .global: environment (.)
    - .uid: string that uniquely identifies this secret within a helm chart
        (can be omitted if name has been provided)
    - .name: name which was used to declare a secret
        (can be omitted if uid has been provided)
    - .key: Key within this secret which value should be assigned to this variable

  Example usage:
  env:
    - name: SECRET_PASSWORD
      {{- include "eric-oss-acm-runtime.secret.envFromSecret" (dict "global" . "uid" "secret" "key" "password") | indent 8}}
*/}}
{{- define "eric-oss-acm-runtime.secret.envFromSecret" -}}
  {{- $key := .key }}
valueFrom:
  secretKeyRef:
    name: {{ include "eric-oss-acm-runtime.secret.getSecretName" . }}
    key: {{ $key }}
{{- end -}}

{{- define "eric-oss-acm-runtime.secret.envFromSecretFast" -}}
  {{- $key := .key }}
valueFrom:
  secretKeyRef:
    name: {{ include "eric-oss-acm-runtime.secret.getSecretNameFast" . }}
    key: {{ $key }}
{{- end -}}

{{/*
  Define secrets to be used by chart.
  Every secret has a type which is one of:
    - generic:
        Generic secret template that allows to input some raw data (from files).
        File Input can be passed as list of files (filePaths) or as a single string
        (filePath)
    - genericKV:
        Type of secret which allows you to define a list of key value pairs.
        The list is assiged to envs value. Every item may define below items:
          - name:
              Identifier of this value within secret
          - value:
              String that defines a value associated with given key.
              This can be a simple string or a template.
          - policy:
              Defines what to do if value is not provided by the user.
              Available options are:
                - generate:
                    Generate a value by derriving it from master password
                - required:
                    Fail the deployment
    - password:
        Type of secret that holds only the password.
        Only two items can be defined for this type:
          - password:
              Equivalent of value field from genericKV
          - policy:
              The same meaning as for genericKV policy field
    - basicAuth:
        Type of secret that holds both username and password.
        Below fields are available:
          - login:
              The value for login key.
              This can be a simple string or a template.
              Providing a value for login is always required.
          - password:
              The value for password key.
              This can be a simple string or a template.
          - passwordPolicy:
              The same meaning as the policy field in genericKV.
              Only the policy for password can be set.

  Every secret can be identified using:
    - uid:
        A string to be appended to the chart fullname to generate a secret name.
    - name:
        Overrides default secret name generation and allows to set immutable
        and globaly unique name
    - annotations:
        List of annotations to be used while defining a secret

  To allow sharing a secret between the components and allow to pre-deploy secrets
  before ONAP deployment it is possible to use already existing secret instead of
  creating a new one. For this purpose externalSecret field can be used. If value of
  this field is evaluated to true no new secret is created, only the name of the
  secret is aliased to the external one.

  Example usage:
    secrets.yaml:
      {{ include "eric-oss-acm-runtime.secret" . }}

    values.yaml:
      mysqlLogin: "root"

      mysqlExternalSecret: "some-other-secret-name"

      secrets:
        - uid: "mysql"
          externalSecret: '{{ tpl .Values.passExternalSecret . }}'
          type: basicAuth
          login: '{{ .Values.mysqlLogin }}'
          mysqlPassword: '{{ .Values.mysqlPassword }}'
          passwordPolicy: generate

    In the above example new secret is not going to be created.
    Already existing one (some-other-secret-name) is going to be used.
    To force creating a new one, just make sure that mysqlExternalSecret
    is not set.

*/}}
{{- define "eric-oss-acm-runtime.secret" -}}
  {{- $global := . }}
  {{- range $secret := .Values.secrets }}
    {{- $uid := tpl (default "" $secret.uid) $global }}
    {{- $name := include "eric-oss-acm-runtime.secret.genName" (dict "global" $global "uid" $uid "name" $secret.name) }}
    {{- $annotations := default "" $secret.annotations }}
    {{- $type := default "generic" $secret.type }}
    {{- $externalSecret := tpl (default "" $secret.externalSecret) $global }}
    {{- if not $externalSecret }}
---
      {{ include "eric-oss-acm-runtime.secret._header" (dict "global" $global "name" $name "annotations" $annotations) }}

      {{- if eq $type "generic" }}
data:
        {{- range $curFilePath := $secret.filePaths }}
          {{ tpl ($global.Files.Glob $curFilePath).AsSecrets $global | indent 2 }}
        {{- end }}
        {{- if $secret.filePath }}
          {{ tpl ($global.Files.Glob $secret.filePath).AsSecrets $global | indent 2 }}
        {{- end }}
      {{- else if eq $type "genericKV" }}
stringData:
        {{- if $secret.envs }}
          {{- range $secretEnv := $secret.envs }}
            {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
    {{ $secretEnv.name }}: {{ include "eric-oss-acm-runtime.secret._value" $valueDesc }}
          {{- end }}
        {{- end }}
      {{- else if eq $type "password" }}
        {{- $secretEnv := (dict "policy" (default "generate" $secret.policy) "name" "password" "value" $secret.password) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
stringData:
  password: {{ include "eric-oss-acm-runtime.secret._value" $valueDesc }}
      {{- else if eq $type "basicAuth" }}
stringData:
        {{- $secretEnv := (dict "policy" "required" "name" "login" "value" $secret.login) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
  login: {{ include "eric-oss-acm-runtime.secret._value" $valueDesc }}
        {{- $secretEnv := (dict "policy" (default "generate" $secret.passwordPolicy) "name" "password" "value" $secret.password) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
  password: {{ include "eric-oss-acm-runtime.secret._value" $valueDesc }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
  Define secrets to be used by chart.
  Every secret has a type which is one of:
    - generic:
        Generic secret template that allows to input some raw data (from files).
        File Input can be passed as list of files (filePaths) or as a single string
        (filePath)
    - genericKV:
        Type of secret which allows you to define a list of key value pairs.
        The list is assiged to envs value. Every item may define below items:
          - name:
              Identifier of this value within secret
          - value:
              String that defines a value associated with given key.
              This can be a simple string or a template.
          - policy:
              Defines what to do if value is not provided by the user.
              Available options are:
                - generate:
                    Generate a value by derriving it from master password
                - required:
                    Fail the deployment
    - password:
        Type of secret that holds only the password.
        Only two items can be defined for this type:
          - password:
              Equivalent of value field from genericKV
          - policy:
              The same meaning as for genericKV policy field
    - basicAuth:
        Type of secret that holds both username and password.
        Below fields are available:
          - login:
              The value for login key.
              This can be a simple string or a template.
              Providing a value for login is always required.
          - password:
              The value for password key.
              This can be a simple string or a template.
          - passwordPolicy:
              The same meaning as the policy field in genericKV.
              Only the policy for password can be set.

  Every secret can be identified using:
    - uid:
        A string to be appended to the chart fullname to generate a secret name.
    - name:
        Overrides default secret name generation and allows to set immutable
        and globaly unique name
    - annotations:
        List of annotations to be used while defining a secret

  To allow sharing a secret between the components and allow to pre-deploy secrets
  before ONAP deployment it is possible to use already existing secret instead of
  creating a new one. For this purpose externalSecret field can be used. If value of
  this field is evaluated to true no new secret is created, only the name of the
  secret is aliased to the external one.

  Example usage:
    secrets.yaml:
      {{ include "eric-oss-acm-runtime.secretFast" . }}

    values.yaml:
      mysqlLogin: "root"

      mysqlExternalSecret: "some-other-secret-name"

      secrets:
        - uid: "mysql"
          externalSecret: '{{ tpl .Values.passExternalSecret . }}'
          type: basicAuth
          login: '{{ .Values.mysqlLogin }}'
          mysqlPassword: '{{ .Values.mysqlPassword }}'
          passwordPolicy: generate

    In the above example new secret is not going to be created.
    Already existing one (some-other-secret-name) is going to be used.
    To force creating a new one, just make sure that mysqlExternalSecret
    is not set.

*/}}
{{- define "eric-oss-acm-runtime.secretFast" -}}
  {{- $global := . }}
  {{- include "eric-oss-acm-runtime.secret.buildCache" $global }}
  {{- range $secret := .Values._secretsCache }}
    {{- $uid := $secret.uid }}
    {{- $externalSecret := $secret.externalSecret }}
    {{- if not $externalSecret }}
      {{- $name := $secret.realName }}
      {{- $annotations := default "" $secret.annotations }}
      {{- $type := default "generic" $secret.type }}
---
      {{ include "eric-oss-acm-runtime.secret._header" (dict "global" $global "name" $name "annotations" $annotations) }}

      {{- if eq $type "generic" }}
data:
        {{- range $curFilePath := $secret.filePaths }}
          {{ tpl ($global.Files.Glob $curFilePath).AsSecrets $global | indent 2 }}
        {{- end }}
        {{- if $secret.filePath }}
          {{ tpl ($global.Files.Glob $secret.filePath).AsSecrets $global | indent 2 }}
        {{- end }}
      {{- else if eq $type "genericKV" }}
stringData:
        {{- if $secret.envs }}
          {{- range $secretEnv := $secret.envs }}
            {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
    {{ $secretEnv.name }}: {{ include "eric-oss-acm-runtime.secret._valueFast" $valueDesc }}
          {{- end }}
        {{- end }}
      {{- else if eq $type "password" }}
        {{- $secretEnv := (dict "policy" (default "generate" $secret.policy) "name" "password" "value" $secret.password) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
stringData:
  password: {{ include "eric-oss-acm-runtime.secret._valueFast" $valueDesc }}
      {{- else if eq $type "basicAuth" }}
stringData:
        {{- $secretEnv := (dict "policy" "required" "name" "login" "value" $secret.login) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
  login: {{ include "eric-oss-acm-runtime.secret._valueFast" $valueDesc }}
        {{- $secretEnv := (dict "policy" (default "generate" $secret.passwordPolicy) "name" "password" "value" $secret.password) }}
        {{- $valueDesc := (dict "global" $global "secretName" $name "secretEnv" $secretEnv) }}
  password: {{ include "eric-oss-acm-runtime.secret._valueFast" $valueDesc }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{- define "eric-oss-acm-runtime.retrieveGeneratedPwd" -}}
  {{- $dot := default . .dot -}}
  {{- $defaultStrength := include "eric-oss-acm-runtime._defaultPasswordStrength" $dot | trim -}}
  {{- $strength := default $defaultStrength .strength -}}
  {{- $mp := include "eric-oss-acm-runtime.masterPassword" $dot -}}
  {{- $uid := default "onap" (printf "%s-%s" (default "eric-oss-pf" $dot.Values.nameOverride) .uid) -}}
  {{- derivePassword 1 $strength $mp (include "eric-oss-acm-runtime.fullname" $dot) $uid -}}
{{- end -}}
