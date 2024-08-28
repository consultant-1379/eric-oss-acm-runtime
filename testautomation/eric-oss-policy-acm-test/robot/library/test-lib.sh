#!/bin/bash
# ********************************************************************
# Copyright (C) 2022 Ericsson Software Technology
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Software Technology. The programs may be used and/or copied
# only with written permission from Ericsson Software Technology or in
# accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# ********************************************************************

set -o pipefail

function load_env_vars() {

    export TEST_DIR=${TEST_DIR:-"robotarchive"}
    export NAMESPACE=${NAMESPACE:-"policy-testing"}
    export HELM_CHART_NAME=${HELM_CHART_NAME:-"eric-oss-acm-runtime"}
    export STORAGE_CLASS_NAME=${STORAGE_CLASS_NAME:-"network-file"}

    if [[ -n ${DOCKER_REGISTRY+x} ]]; then
        export DOCKER_REGISTRY=${DOCKER_REGISTRY}
    else
        echo "Info      : Please specify DOCKER_REGISTRY env variable"
        echo "Example   : export DOCKER_REGISTRY=aegis-strimzi-docker-local.artifactory.est.tech"
        exit 1
    fi

    if [[ -n ${DOCKER_ORG+x} ]]; then
        export DOCKER_ORG=${DOCKER_ORG}
    else
        echo "Info      : Please specify DOCKER_ORG env variable"
        echo "Example   : export DOCKER_ORG=proj-est-poc/strimzi"
        exit 1
    fi

    if [[ -n ${POLICY_RUNTIME_ACM_TEST_CASE+x} ]]; then
        export POLICY_RUNTIME_ACM_TEST_CASE=${POLICY_RUNTIME_ACM_TEST_CASE}
    else
        echo "Info      : Please specify POLICY_RUNTIME_ACM_TEST_CASE env variable"
        echo "Example   : export POLICY_RUNTIME_ACM_TEST_CASE=CommissionAutomationCompositionV1"
        exit 1
    fi

    if [[ -n ${IMAGE_NAME+x} ]]; then
        export IMAGE_NAME=${IMAGE_NAME}
    else
        echo "Info      : Please specify IMAGE_NAME env variable"
        echo "Example   : export IMAGE_NAME=bridge-test-image"
        exit 1
    fi

    if [[ -n ${IMAGE_TAG+x} ]]; then
        export IMAGE_TAG=${IMAGE_TAG}
    else
        echo "Info      : Please specify IMAGE_TAG env variable"
        echo "Example   : export IMAGE_TAG=0.21.4-precode"
        exit 1
    fi

    if [[ -n ${IMAGE_PULL_SECRET+x} ]]; then
        export IMAGE_PULL_SECRET=${IMAGE_PULL_SECRET}
    else
        echo "Info      : Please specify IMAGE_PULL_SECRET env variable"
        echo "Example   : export IMAGE_PULL_SECRET=armdocker"
        exit 1
    fi

    export IMAGE_PATH="$DOCKER_REGISTRY/$DOCKER_ORG/$IMAGE_NAME:$IMAGE_TAG"
    log_env
}

function load_build_env_vars() {

     if [[ -n ${DOCKER_IMAGE_TAG+x} ]]; then
        export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}
    else
        echo "Info      : Please specify DOCKER_IMAGE_TAG env variable"
        echo "Example   : export DOCKER_IMAGE_TAG=aegis-strimzi-docker-local.artifactory.est.tech/strimzi/acm-robot-image:0.21.4-precode"
        exit 1
    fi
}

function load_helm_env_var() {
    export NAMESPACE=${NAMESPACE:-"policy-testing"}
    export HELM_CHART_NAME=${HELM_CHART_NAME:-"eric-oss-csit-test"}

    if [[ -n ${IMAGE_TAG+x} ]]; then
        export IMAGE_TAG=${IMAGE_TAG}
    else
        echo "Info      : Please specify IMAGE_TAG env variable"
        echo "Example   : export IMAGE_TAG=0.21.4-precode"
        exit 1
    fi

    log_helm_install_env
}

function log_helm_install_env() {
  echo
  echo "#---------------------------------------------------#"
  echo "#          Environment variables                    #"
  echo "#---------------------------------------------------#"
  echo "NAMESPACE                   : $NAMESPACE"
  echo "HELM_CHART_NAME             : $HELM_CHART_NAME"
  echo "IMAGE_TAG                   : $IMAGE_TAG"
  echo "#---------------------------------------------------#"
  echo

}
#-------------------------------------------------------------------------------
# Log env variables required for test to run
#-------------------------------------------------------------------------------
function log_env() {

  echo
  echo "#---------------------------------------------------#"
  echo "#          Environment variables                    #"
  echo "#---------------------------------------------------#"
  echo "TEST_DIR                    : $TEST_DIR"
  echo "POLICY_RUNTIME_ACM_TEST_CASE: $POLICY_RUNTIME_ACM_TEST_CASE"
  echo "NAMESPACE                   : $NAMESPACE"
  echo "HELM_CHART_NAME             : $HELM_CHART_NAME"
  echo "STORAGE_CLASS_NAME          : $STORAGE_CLASS_NAME"
  echo "DOCKER_REGISTRY             : $DOCKER_REGISTRY"
  echo "DOCKER_ORG                  : $DOCKER_ORG"
  echo "IMAGE_NAME                  : $IMAGE_NAME"
  echo "IMAGE_TAG                   : $IMAGE_TAG"
  echo "IMAGE_PULL_SECRET           : $IMAGE_PULL_SECRET"
  echo "IMAGE_PATH                  : $IMAGE_PATH"
  echo "#---------------------------------------------------#"
  echo

}

function retry() {
  local -r -i max_attempts="$1"; shift
  local -r cmd="$@"
  local -i attempt_num=1

  echo "Info: inside retry function"
  until $cmd
  do
    if (( attempt_num == max_attempts ));
    then
       echo "Attempt $max_attempts failed. Giving up."
       return 1
    else
       echo "Attempt $attempt_num= failed. Retrying in 5 seconds..."
       ((attempt_num++))
       sleep 5
    fi
  done
}


#-------------------------------------------------------------------------------
# Function to clean up kubernets test reources from previous runs
#-------------------------------------------------------------------------------
function cleanup() {

  echo "Info  : Remove leftovers of previous run"

  ROBOT_TEST_JOB_NAME=$(kubectl -n "$NAMESPACE" get jobs | grep acm-robot-test | sed 's/|//'| awk '{print $1}') || true

  echo "Info: ACM test job name : ${ROBOT_TEST_JOB_NAME}"
  if [[ ! -z "${ROBOT_TEST_JOB_NAME}" ]]; then
      retry 3 kubectl -n "$NAMESPACE" delete job "${ROBOT_TEST_JOB_NAME}" --timeout=60s || true
  else
    echo "No ACM Robot test Job in namespace: $NAMESPACE"
  fi

  ROBOT_TEST_PVC_NAME=$(kubectl -n "$NAMESPACE" get pvc | grep acm-robot-test | sed 's/|//' | awk '{print $1}') || true

  echo "ACM Robot test PVC name : ${ROBOT_TEST_PVC_NAME}"
  if [[ ! -z "${ROBOT_TEST_PVC_NAME}" ]]; then
      retry 3 kubectl -n "$NAMESPACE" delete pvc "${ROBOT_TEST_PVC_NAME}" || true
  else
    echo "No ACM Robot test PVC in namespace: $NAMESPACE"
  fi

  ROBOT_TEST_NETPOL_NAME=$(kubectl -n "$NAMESPACE" get netpol | grep acm-robot-test | sed 's/|//' | awk '{print $1}') || true

  echo "ACM robot test Network policy name : ${ROBOT_TEST_NETPOL_NAME}"
  if [[ ! -z "${ROBOT_TEST_NETPOL_NAME}" ]]; then
      retry 3 kubectl -n "$NAMESPACE" delete netpol "${ROBOT_TEST_NETPOL_NAME}" || true
  else
    echo "No ACM robot test Network policy in namespace: $NAMESPACE"
  fi

}

#-------------------------------------------------------------------------------
# Function to clean up kubernets CSIT test helm release from previous runs
#-------------------------------------------------------------------------------
function helm_cleanup() {
  echo "Info  : Removing helm release of previous run"

  local HELM_RELEASE_NAME=$(helm -n "$NAMESPACE" ls | grep "$HELM_CHART_NAME" | sed 's/|//'| awk '{print $1}')
  if [[ ! -z "${HELM_RELEASE_NAME}" ]]; then
      retry 3 helm -n "$NAMESPACE" uninstall "${HELM_RELEASE_NAME}" || true
  else
    echo "No Helm release found in the namespace: $NAMESPACE"
  fi

}

#-------------------------------------------------------------------------------
# Function to get Robot test report
#-------------------------------------------------------------------------------
function generate_report() {
    local REPORT=$1
    local FILE_NAME=$2
    # dir of script
    local SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
    # parent dir of that dir
    local REPORT_DIR="${SCRIPT_DIR%/*}/reports"

    if [[ ! -d  $REPORT_DIR ]]; then
        echo "No reports directory found, creating it...."
        mkdir $REPORT_DIR
    fi

    echo "$REPORT" > "$REPORT_DIR/$FILE_NAME"
}
