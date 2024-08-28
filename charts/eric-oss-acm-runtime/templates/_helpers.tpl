{{/*
 *******************************************************************************
 * Copyright (C) 2022-2024 Ericsson Software Technology
 *
 * The copyright to the computer program(s) herein is the property of
 * Ericsson Software Technology. The programs may be used and/or copied
 * only with written permission from Ericsson Software Technology or in
 * accordance with the terms and conditions stipulated in the
 * agreement/contract under which the program(s) have been supplied.
 *******************************************************************************
 */}}

{{/*
Call index function recursively. Check on each recursive call that the key exists. Instead of throwing an error if the key doesn't exist, do nothing.

The return type is always String. If another return type is required, use this function to test if the value exists and then access that value with the index function.
*/}}
{{- define "eric-oss-acm-runtime.indexRecursive" -}}
    {{- $keys := (rest .) -}}
    {{- $dict := first . -}}
    {{- $innerValue := index $dict (first $keys) -}}
    {{ if not (kindIs "invalid" $innerValue) }}
        {{- $keysLeft := rest $keys -}}
        {{- if $keysLeft -}}
            {{- $args := prepend $keysLeft $innerValue -}}
            {{- include "eric-oss-acm-runtime.indexRecursive" $args -}}
        {{- else -}}
            {{- $innerValue -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Given a list of .Values and any number of optional parameter names (including path), returns the first parameter that has a value.
Uses the indexRecursive function, so it is safe to use even if a parameter is not defined.
*/}}
{{- define "eric-oss-acm-runtime.firstOptional" -}}
    {{- $values := first . -}}
     {{- $parameters := rest . -}}
     {{- if $parameters -}}
         {{- $currentParameter := first $parameters -}}
         {{- $indexRecursiveArgs := prepend (splitList "." $currentParameter) $values -}}
         {{- $currentValue := include "eric-oss-acm-runtime.indexRecursive" $indexRecursiveArgs -}}
         {{- if $currentValue -}}
             {{- $currentValue -}}
         {{- else -}}
             {{- $remainingParameters := rest $parameters -}}
             {{- $recursiveArgs := prepend $remainingParameters $values -}}
             {{- include "eric-oss-acm-runtime.firstOptional" $recursiveArgs -}}
         {{- end -}}
     {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-oss-acm-runtime.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart version.
*/}}
{{- define "eric-oss-acm-runtime.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-acm-runtime.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "eric-oss-acm-runtime-configmap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "eric-oss-acm-runtime-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create release name used for cluster role.
*/}}
{{- define "eric-oss-acm-runtime.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-oss-acm-runtime.registryUrl" -}}
{{- if .Values.imageCredentials.registry -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else if .Values.global -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{ end }}
{{- else -}}
""
{{- end -}}
{{- else if .Values.global -}}
{{- if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{ end }}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-oss-acm-runtime.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ include "eric-oss-acm-runtime.name" . }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-oss-acm-runtime.eric-product-info" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end}}

{{/*
The runtimeImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-acm-runtime.mainImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.runtimeImage.registry -}}
    {{- $repoPath := $productInfo.images.runtimeImage.repoPath -}}
    {{- $name := $productInfo.images.runtimeImage.name -}}
    {{- $tag := $productInfo.images.runtimeImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if .Values.imageCredentials.runtimeImage -}}
            {{- if .Values.imageCredentials.runtimeImage.registry -}}
                {{- if .Values.imageCredentials.runtimeImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.runtimeImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.runtimeImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.runtimeImage.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.images -}}
        {{- if .Values.images.runtimeImage -}}
            {{- if .Values.images.runtimeImage.name -}}
                {{- $name = .Values.images.runtimeImage.name -}}
            {{- end -}}
            {{- if .Values.images.runtimeImage.tag -}}
                {{- $tag = .Values.images.runtimeImage.tag -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The runtimeImage pull policy
*/}}
{{- define "eric-oss-acm-runtime.imagePullPolicy" -}}
    {{- include "eric-oss-acm-runtime.firstOptional" (list .Values "imageCredentials.runtimeImage.registry.imagePullPolicy" "global.registry.imagePullPolicy") | default "IfNotPresent" -}}
{{- end -}}

{{/*
The readinessImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-acm-runtime.readinessImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.readinessImage.registry -}}
    {{- $repoPath := $productInfo.images.readinessImage.repoPath -}}
    {{- $name := $productInfo.images.readinessImage.name -}}
    {{- $tag := $productInfo.images.readinessImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if .Values.imageCredentials.readinessImage -}}
            {{- if .Values.imageCredentials.readinessImage.registry -}}
                {{- if .Values.imageCredentials.readinessImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.readinessImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.readinessImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.readinessImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The envsubstImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-acm-runtime.envsubstImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.envsubstImage.registry -}}
    {{- $repoPath := $productInfo.images.envsubstImage.repoPath -}}
    {{- $name := $productInfo.images.envsubstImage.name -}}
    {{- $tag := $productInfo.images.envsubstImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if .Values.imageCredentials.envsubstImage -}}
            {{- if .Values.imageCredentials.envsubstImage.registry -}}
                {{- if .Values.imageCredentials.envsubstImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.envsubstImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.envsubstImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.envsubstImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The postgresImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-acm-runtime.postgresImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.postgresImage.registry -}}
    {{- $repoPath := $productInfo.images.postgresImage.repoPath -}}
    {{- $name := $productInfo.images.postgresImage.name -}}
    {{- $tag := $productInfo.images.postgresImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if .Values.imageCredentials.postgresImage -}}
            {{- if .Values.imageCredentials.postgresImage.registry -}}
                {{- if .Values.imageCredentials.postgresImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.postgresImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.postgresImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.postgresImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The migratorImage path (DR-D1121-067)
*/}}
{{- define "eric-oss-acm-runtime.migratorImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.migratorImage.registry -}}
    {{- $repoPath := $productInfo.images.migratorImage.repoPath -}}
    {{- $name := $productInfo.images.migratorImage.name -}}
    {{- $tag := $productInfo.images.migratorImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if .Values.imageCredentials.migratorImage -}}
            {{- if .Values.imageCredentials.migratorImage.registry -}}
                {{- if .Values.imageCredentials.migratorImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.migratorImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.migratorImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.migratorImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <release_name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-oss-acm-runtime.privileged.cluster.role.name" -}}
{{- $privilegedClusterRoleName := printf "%s%s" (include "eric-oss-acm-runtime.name" . ) "-allowed-use-privileged-policy" -}}
{{- if .Values.global -}}
  {{- if .Values.global.security -}}
    {{- if hasKey (.Values.global.security) "privilegedPolicyClusterRoleName" -}}
      {{- $privilegedClusterRoleName = .Values.global.security.privilegedPolicyClusterRoleName }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $privilegedClusterRoleName -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.securityPolicy.reference" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.security -}}
      {{- if .Values.global.security.policyReferenceMap -}}
        {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
        {{- if $mapped -}}
          {{ $mapped }}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
      {{- else -}}
        default-restricted-security-policy
      {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
  {{- else -}}
    default-restricted-security-policy
  {{- end -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.securityPolicy.annotations" -}}
# Automatically generated annotations for documentation purposes.
{{- end -}}

{{/*
Create a user defined annotation (DR-D1121-065, DR-D1121-060)
*/}}
{{ define "eric-oss-acm-runtime.config-annotations" }}
  {{- $global := (.Values.global).annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-oss-acm-runtime.mergeAnnotations" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged annotations for Default, which includes productInfo and config
*/}}
{{- define "eric-oss-acm-runtime.annotations" -}}
  {{- $productInfo := include "eric-oss-acm-runtime.eric-product-info" . | fromYaml -}}
  {{- $config := include "eric-oss-acm-runtime.config-annotations" . | fromYaml -}}
  {{- include "eric-oss-acm-runtime.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $config)) | trim }}
{{- end -}}

{{/*
Standard labels of Helm and Kubernetes
*/}}
{{- define "eric-oss-acm-runtime.standard-labels" -}}
app.kubernetes.io/name: {{ include "eric-oss-acm-runtime.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "eric-oss-acm-runtime.version" . }}
helm.sh/chart: {{ include "eric-oss-acm-runtime.chart" . }}
chart: {{ include "eric-oss-acm-runtime.chart" . }}
{{- end -}}

{{- define "eric-oss-acm-runtime.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.runtimeImage.registry -}}
        {{- if .Values.imageCredentials.runtimeImage.registry.imagePullPolicy -}}
        {{- $globalRegistryPullPolicy = .Values.imageCredentials.runtimeImage.registry.imagePullPolicy -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{/*
Create image pull secrets for global (outside of scope)
*/}}
{{- define "eric-oss-acm-runtime.pullSecret.global" -}}
{{- $pullSecret := "" -}}
{{- if .Values.global -}}
  {{- if .Values.global.pullSecret -}}
    {{- $pullSecret = .Values.global.pullSecret -}}
  {{- end -}}
  {{- end -}}
{{- print $pullSecret -}}
{{- end -}}

{{/*
Create image pull secret, service level parameter takes precedence
*/}}
{{- define "eric-oss-acm-runtime.pullSecret" -}}
{{- $pullSecret := (include "eric-oss-acm-runtime.pullSecret.global" . ) -}}
{{- if .Values.imageCredentials -}}
  {{- if .Values.imageCredentials.pullSecret -}}
    {{- $pullSecret = .Values.imageCredentials.pullSecret -}}
  {{- end -}}
{{- end -}}
{{- print $pullSecret -}}
{{- end -}}

{{/*
check global.security.tls.enabled
*/}}
{{- define "eric-oss-acm-runtime.global-security-tls-enabled" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.security -}}
            {{- if .Values.global.security.tls -}}
                {{- .Values.global.security.tls.enabled | toString -}}
            {{- else -}}
                {{- "false" -}}
            {{- end -}}
        {{- else -}}
            {{- "false" -}}
        {{- end -}}
    {{- else -}}
        {{- "false" -}}
    {{- end -}}
{{- end -}}

{{/*
DR-D470217-007-AD This helper defines whether this service enter the Service Mesh or not.
*/}}
{{- define "eric-oss-acm-runtime.service-mesh-enabled" }}
    {{- $globalMeshEnabled := "true" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.serviceMesh -}}
            {{- $globalMeshEnabled = .Values.global.serviceMesh.enabled -}}
        {{- end -}}
    {{- end -}}
    {{- $globalMeshEnabled -}}
{{- end -}}

{{/*
DR-D470217-011 This helper defines the annotation which bring the service into the mesh.
*/}}
{{- define "eric-oss-acm-runtime.service-mesh-inject" }}
    {{- if eq (include "eric-oss-acm-runtime.service-mesh-enabled" .) "true" }}
sidecar.istio.io/inject: "true"
    {{- else -}}
sidecar.istio.io/inject: "false"
    {{- end -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.istio-proxy-config-annotation" }}
    {{- if eq (include "eric-oss-acm-runtime.service-mesh-enabled" .) "true" }}
proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
    {{- end -}}
{{- end -}}


{{/*
GL-D470217-080-AD
This helper captures the service mesh version from the integration chart to
annotate the workloads so they are redeployed in case of service mesh upgrade.
*/}}
{{- define "eric-oss-acm-runtime.service-mesh-version" }}
    {{- if eq (include "eric-oss-acm-runtime.service-mesh-enabled" .) "true" }}
    {{- if .Values.global }}
        {{- if .Values.global.serviceMesh -}}
            {{- if .Values.global.serviceMesh.annotations -}}
                {{ .Values.global.serviceMesh.annotations | toYaml }}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
This helper defines the annotation for define service mesh volume
*/}}
{{- define "eric-oss-acm-runtime.service-mesh-volume" }}
{{- $serviceMesh := ( include "eric-oss-acm-runtime.service-mesh-enabled" .) -}}
{{- $tls := ( include "eric-oss-acm-runtime.global-security-tls-enabled" .) -}}
{{- if and (eq $serviceMesh "true") (eq $tls "true") -}}
sidecar.istio.io/userVolume: |-
  {
    "{{ include "eric-oss-acm-runtime.name" . }}-pg-certs-tls": {
      "secret": {
        "secretName": "{{ include "eric-oss-acm-runtime.name" . }}-{{ .Values.db.service.name }}-secret",
        "optional": true
      }
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-root-pg-certs-tls": {
      "secret": {
        "secretName": "{{ include "eric-oss-acm-runtime.name" . }}-{{ .Values.db.service.name }}-root-secret",
        "optional": true
      }
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-kafka-certs-tls": {
      "secret": {
        "secretName": "{{ include "eric-oss-acm-runtime.name" . }}-{{ include "eric-oss-acm-runtime.kafkaClusterName" .}}-secret",
        "optional": true
      }
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-dst-certs-tls": {
      "secret": {
        "secretName": "{{ include "eric-oss-acm-runtime.name" . }}-dst-secret",
        "optional": true
      }
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-certs-ca-tls": {
      "secret": {
        "secretName": "eric-sec-sip-tls-trusted-root-cert"
      }
    }
  }
sidecar.istio.io/userVolumeMount: |-
  {
    "{{ include "eric-oss-acm-runtime.name" . }}-pg-certs-tls": {
      "mountPath": "/etc/istio/tls/{{ .Values.db.service.name }}/",
      "readOnly": true
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-root-pg-certs-tls": {
      "mountPath": "/etc/istio/tls/{{ .Values.db.service.name }}-root/",
      "readOnly": true
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-kafka-certs-tls": {
      "mountPath": "/etc/istio/tls/{{ include "eric-oss-acm-runtime.kafkaClusterName" .}}/",
      "readOnly": true
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-dst-certs-tls": {
      "mountPath": "/etc/istio/tls/{{ .Values.dst.service.name }}/",
      "readOnly": true
    },
    "{{ include "eric-oss-acm-runtime.name" . }}-certs-ca-tls": {
      "mountPath": "/etc/istio/tls-ca",
      "readOnly": true
    }
  }
{{ end }}
{{- end -}}

{{/*
This helper defines which out-mesh services are reached by the <service-name>.
*/}}
{{- define "eric-oss-acm-runtime.service-mesh-ism2osm-labels" }}
  {{- $serviceMesh := ( include "eric-oss-acm-runtime.service-mesh-enabled" .) -}}
  {{- $tls := ( include "eric-oss-acm-runtime.global-security-tls-enabled" .) -}}
  {{- if and (eq $serviceMesh "true") (eq $tls "true") -}}
{{ .Values.db.service.name }}-ism-access: "true"
{{ .Values.db.service.name }}-root-ism-access: "true"
{{ include "eric-oss-acm-runtime.kafkaClusterName" .}}-ism-access: "true"
{{ .Values.dst.service.name }}-ism-access: "true"
  {{- end }}
{{- end -}}

{{/*
Get the name of the Kafka Cluster
*/}}
{{- define "eric-oss-acm-runtime.kafkaClusterName" }}
{{- $kafkaClusterName := "kafka-cluster"}}
{{- if .Values.global }}
    {{- if .Values.global.kafkaClusterName}}
        {{- $kafkaClusterName = .Values.global.kafkaClusterName }}
        {{- print $kafkaClusterName -}}
    {{- else -}}
        {{ print $kafkaClusterName }}
    {{- end -}}
{{- else -}}
    {{ print $kafkaClusterName }}
{{- end -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.dbuser" -}}
{{ $externalSecretName := "" }}
{{ if  .Values.db.credsExternalSecret }}
{{- $externalSecretName = .Values.db.credsExternalSecret -}}
{{ end }}
{{- $releaseNamespace := .Release.Namespace -}}
{{- if and $externalSecretName (lookup "v1" "Secret" $releaseNamespace $externalSecretName) -}}
  {{- $externalSecret := (lookup "v1" "Secret" $releaseNamespace $externalSecretName) -}}
  {{ index $externalSecret.data "login" | b64dec }}
{{- else -}}
  {{- default (randAlpha 10) .Values.db.user -}}
{{- end -}}
{{- end -}}

{{/*
Define kafka bootstrap server
*/}}

{{- define "eric-oss-acm-runtime.kafka-bootstrap-server" -}}
{{- $kafkaBootstrapServer := "kafka-bootstrap:9092" -}}
{{- $serviceMesh := ( include "eric-oss-acm-runtime.service-mesh-enabled" .) -}}
{{- $tls := ( include "eric-oss-acm-runtime.global-security-tls-enabled" .) -}}
{{- if .Values.kafkaConfig.localKafkaCluster -}}
    {{- $kafkaBootstrapServer = printf "%s-%s" (include "eric-oss-acm-runtime.name" .) "kafka-bootstrap:9092" -}}
{{- else if and (eq $serviceMesh "true") (eq $tls "true") -}}
    {{ if .Values.global }}
    {{ if .Values.global.kafkaBootstrapTls }}
    {{- $kafkaBootstrapServer = .Values.global.kafkaBootstrapTls -}}
    {{- end -}}
    {{- end -}}
{{- else -}}
    {{ if .Values.global }}
    {{ if .Values.global.kafkaBootstrap }}
    {{- $kafkaBootstrapServer = .Values.global.kafkaBootstrap -}}
    {{- end -}}
    {{- end -}}
{{ end }}
{{- print $kafkaBootstrapServer -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-oss-acm-runtime.nodeSelector" -}}
{{- $globalValue := (dict) -}}
{{- if .Values.global -}}
  {{- if .Values.global.nodeSelector -}}
    {{- $globalValue = .Values.global.nodeSelector -}}
  {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector -}}
  {{- range $key, $localValue := .Values.nodeSelector -}}
    {{- if hasKey $globalValue $key -}}
      {{- $Value := index $globalValue $key -}}
        {{- if ne $Value $localValue -}}
          {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
    nodeSelector: {{- toYaml (merge $globalValue .Values.nodeSelector) | trim | nindent 2 -}}
{{- else -}}
  {{- if not ( empty $globalValue ) -}}
    nodeSelector: {{- toYaml $globalValue | trim | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.log-streamingMethod" -}}
  {{- $streamingMethod := "indirect" -}}
  {{- if ((.Values.log).streamingMethod) -}}
    {{- $streamingMethod = .Values.log.streamingMethod -}}
  {{- else if (((.Values.global).log).streamingMethod) -}}
    {{- $streamingMethod = .Values.global.log.streamingMethod -}}
  {{- else if ((.Values.log).outputs) -}}
    {{- if and (has "stdout" .Values.log.outputs) (has "stream" .Values.log.outputs) -}}
    {{- $streamingMethod = "dual" -}}
    {{- else if has "stream" .Values.log.outputs -}}
    {{- $streamingMethod = "direct" -}}
    {{- else if has "stdout" .Values.log.outputs -}}
    {{- $streamingMethod = "indirect" -}}
    {{- end -}}
  {{- else if (((.Values.global).log).outputs) -}}
    {{- if and (has "stdout" .Values.global.log.outputs) (has "stream" .Values.global.log.outputs) -}}
    {{- $streamingMethod = "dual" -}}
    {{- else if has "stream" .Values.global.log.outputs -}}
    {{- $streamingMethod = "direct" -}}
    {{- else if has "stdout" .Values.global.log.outputs -}}
    {{- $streamingMethod = "indirect" -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" $streamingMethod -}}
{{- end -}}



{{- define "eric-oss-acm-runtime.log-streaming-activated" }}
  {{- $streamingMethod := (include "eric-oss-acm-runtime.log-streamingMethod" .) -}}
  {{- if or (eq $streamingMethod "dual") (eq $streamingMethod "direct") -}}
    {{- printf "%t" true -}}
  {{- else -}}
    {{- printf "%t" false -}}
  {{- end -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.seccomp-profile" }}
    {{- if .Values.seccompProfile }}
      {{- if .Values.seccompProfile.type }}
          {{- if eq .Values.seccompProfile.type "Localhost" }}
              {{- if .Values.seccompProfile.localhostProfile }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
  localhostProfile: {{ .Values.seccompProfile.localhostProfile }}
              {{- end }}
          {{- else }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
          {{- end }}
      {{- end }}
    {{- end }}
{{- end }}

{{/*
Create prometheus info
*/}}
{{- define "eric-oss-acm-runtime.prometheus" -}}
prometheus.io/scrape: {{ .Values.prometheus.scrape | quote }}
prometheus.io/port: {{ .Values.prometheus.port | quote }}
prometheus.io/path: {{ .Values.prometheus.path | quote }}
prometheus.io/scrape-role: {{ .Values.prometheus.role | quote }}
prometheus.io/scrape-interval: {{ .Values.prometheus.interval | quote }}
{{- end -}}

{{/*
Define eric-oss-acm-runtime.apparmor-annotations DR-D1123-127
*/}}
{{- define "eric-oss-acm-runtime.apparmor-annotations" }}
{{- $appArmorValue := .Values.appArmorProfile.type -}}
    {{- if .Values.appArmorProfile -}}
        {{- if .Values.appArmorProfile.type -}}
            {{- if eq .Values.appArmorProfile.type "localhost" -}}
                {{- $appArmorValue = printf "%s/%s" .Values.appArmorProfile.type .Values.appArmorProfile.localhostProfile }}
            {{- end}}
container.apparmor.security.beta.kubernetes.io/{{ include "eric-oss-acm-runtime.name" .}}: {{ $appArmorValue | quote }}
container.apparmor.security.beta.kubernetes.io/{{ include "eric-oss-acm-runtime.name" .}}-readiness: {{ $appArmorValue | quote }}
container.apparmor.security.beta.kubernetes.io/{{ include "eric-oss-acm-runtime.name" .}}-update-config: {{ $appArmorValue | quote }}
        {{- end}}
    {{- end}}
{{- end}}

{{/*
This helper defines whether DST is enabled or not.
*/}}
{{- define "eric-oss-acm-runtime.dst-enabled" }}
  {{- $dstEnabled := "false" -}}
  {{- if .Values.dst -}}
    {{- if .Values.dst.enabled -}}
        {{- $dstEnabled = .Values.dst.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $dstEnabled -}}
{{- end -}}

{{/*
Define the labels needed for DST
*/}}
{{- define "eric-oss-acm-runtime.dstLabels" -}}
{{- if eq (include "eric-oss-acm-runtime.dst-enabled" .) "true" }}
eric-dst-collector-access: "true"
{{- end }}
{{- end -}}

{{/*
This helper defines which exporter port must be used depending on protocol
*/}}
{{- define "eric-oss-acm-runtime.exporter-port" }}
  {{- $dstExporterPort := .Values.dst.collector.portOtlpGrpc -}}
    {{- if .Values.dst.collector.protocol -}}
      {{- if eq .Values.dst.collector.protocol "http" -}}
        {{- $dstExporterPort = .Values.dst.collector.portOtlpHttp -}}
      {{- end -}}
    {{- end -}}
  {{- $dstExporterPort -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.ipFamliy" }}
{{- if .Values.global }}
  {{- if .Values.global.internalIPFamily }}
ipFamilies: [{{ .Values.global.internalIPFamily }}]
  {{- end }}
{{- end }}
{{- end -}}

{{/*
This helper defines whether DST is enabled or not.
*/}}
{{- define "eric-oss-acm-runtime.dst-kafka-protocol" }}
  {{- $protocol := "grpc" -}}
  {{- if eq .Values.dst.collector.protocol "http" -}}
      {{- $protocol = "http/protobuf" -}}
  {{- end -}}
  {{- $protocol -}}
{{- end -}}

{{- define "eric-oss-acm-runtime.timeout" -}}
{{ if .Values.global -}}
  {{ if .Values.global.acmOperationTimeout -}}
    {{- printf " %d" (int .Values.global.acmOperationTimeout) -}}
  {{- else -}}
    {{ printf " %d" (int .Values.timeout) -}}
  {{ end -}}
{{ else -}}
  {{ printf " %d" (int .Values.timeout) -}}
{{ end }}
{{- end }}

{{/*
Create the fsGroup value according to DR-D1123-136.
*/}}
{{- define "eric-oss-acm-runtime.fsGroup-coordinated" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.fsGroup -}}
      {{- if not (kindIs "invalid" .Values.global.fsGroup.manual) -}}
        {{- if (kindIs "string" .Values.global.fsGroup.manual) -}}
          {{- fail "global.fsGroup.manual shall be a positive integer or 0 and not a string" }}
        {{- end -}}
        {{- if ge (.Values.global.fsGroup.manual | int ) 0 }}
          {{- .Values.global.fsGroup.manual | int }}
        {{- else }}
          {{- fail "global.fsGroup.manual shall be a positive integer or 0 if given" }}
        {{- end }}
      {{- else -}}
        {{- if not (kindIs "invalid" .Values.global.fsGroup.namespace) -}}
          {{- if eq (.Values.global.fsGroup.namespace | toString) "true" -}}
            # The 'default' defined in the Security Policy will be used.
          {{- else }}
            {{- if eq (.Values.global.fsGroup.namespace | toString) "false" -}}
              10000
            {{- else }}
              {{- fail "global.fsGroup.namespace shall be true or false if given" }}
            {{- end -}}
          {{- end -}}
        {{- else -}}
          10000
        {{- end -}}
      {{- end -}}
    {{- else -}}
      10000
    {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
{{- end -}}

{{/*
Define tolerations
*/}}
{{- define "eric-oss-acm-runtime.tolerations" -}}
{{- $tolerations := list -}}
{{- if .Values.tolerations -}}
  {{- if ne (len .Values.tolerations) 0 -}}
    {{- range $t := .Values.tolerations -}}
      {{- $tolerations = append $tolerations $t -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if .Values.global -}}
  {{- if .Values.global.tolerations -}}
    {{- if ne (len .Values.global.tolerations) 0 -}}
      {{- range $t := .Values.global.tolerations -}}
        {{- $tolerations = append $tolerations $t -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{ toYaml $tolerations }}
{{- end -}}