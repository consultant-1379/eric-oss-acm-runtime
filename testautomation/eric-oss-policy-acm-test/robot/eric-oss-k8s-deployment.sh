#! /bin/bash

set -o nounset
set -o errexit
set -o pipefail

# Source libraries
WORKSPACE=$(dirname "${BASH_SOURCE}")
source "$WORKSPACE/library/test-lib.sh"

echo "---------------------------------------------"
echo "Load all env variables"
echo "---------------------------------------------"
load_env_vars

echo "---------------------------------------------"
echo "Deploying kubernetes ACM CSIT test in cluster"
echo "---------------------------------------------"
cleanup

HELM_RELEASE_NAME=$(helm -n "$NAMESPACE" ls | grep "$HELM_CHART_NAME" | sed 's/|//'| awk '{print $1}')

if [[ ! -n ${HELM_RELEASE_NAME+x} ]]; then
    echo_log "Error: Helm Release not found for chart $HELM_CHART_NAME in namespace $NAMESPACE" ${TEST_TYPE}
    exit 1
fi

ACM_DEPLOYMENT_NAME=$(kubectl -n "$NAMESPACE" get deployment | grep "$HELM_CHART_NAME" | sed 's/|//'| awk '{print $1}')

if [[ ! -n ${ACM_DEPLOYMENT_NAME+x} ]]; then
    echo "Error: ACM deployment not found for chart $HELM_CHART_NAME in namespace $NAMESPACE"
    exit 1
fi
echo "HELM_RELEASE_NAME: $HELM_RELEASE_NAME"
echo "Deployment name : $ACM_DEPLOYMENT_NAME"

ACM_SERVICE_HOST=$(kubectl -n "$NAMESPACE" get svc | grep -m1 "$HELM_CHART_NAME" | sed 's/|//'| awk '{print $1}')
echo "ACM Serice name : $ACM_SERVICE_HOST"

export POLICY_RUNTIME_ACM_TEST_CASE=$POLICY_RUNTIME_ACM_TEST_CASE

export POLICY_RUNTIME_ACM_IP=$ACM_SERVICE_HOST

POLICY_APP_USER_CREDS=$(kubectl -n "$NAMESPACE" get secrets | grep policy-app-user-creds | awk '{print $1}')
POLICY_ADMIN_PASSWORD=$(kubectl -n "$NAMESPACE" get secrets "$POLICY_APP_USER_CREDS" -o jsonpath='{.data.password}' | base64 -d)

export POLICY_ADMIN_PASSWORD=$POLICY_ADMIN_PASSWORD

echo "Info: Creating PVC for acm test"

envsubst < $WORKSPACE/kubernetes/eric-oss-acm-robot-test-pvc.yaml | kubectl apply -n "$NAMESPACE" -f -

echo "Info: Creating network policy for acm-test"

envsubst < $WORKSPACE/kubernetes/eric-oss-acm-robot-test-network-policy.yaml | kubectl apply -n "$NAMESPACE" -f -

kubectl -n "$NAMESPACE" get netpol

echo "Info: Running robot acm csit tests"

envsubst < $WORKSPACE/kubernetes/eric-oss-acm-robot-test-job.yaml | kubectl apply -n "$NAMESPACE" -f -

ROBOT_TEST_JOB_NAME=$(kubectl -n "$NAMESPACE" get jobs | grep acm-robot-test | sed 's/|//'| awk '{print $1}')

ROBOT_TEST_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep acm-robot-test | sed 's/|//'| awk '{print $1}')

sleep 1m

TEST_DESCRIBE="$(kubectl -n $NAMESPACE describe pod $ROBOT_TEST_POD_NAME)"

echo "$TEST_DESCRIBE"

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/"$ROBOT_TEST_JOB_NAME" || true

TEST_LOG="$(kubectl -n $NAMESPACE logs $ROBOT_TEST_POD_NAME)"

echo "$TEST_LOG"

echo "Info: Reading ACM robot report from report job"

kubectl apply -n "$NAMESPACE" -f $WORKSPACE/kubernetes/eric-oss-acm-robot-test-report-job.yaml

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/acm-robot-test-report-job || true

TEST_REPORT_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep acm-robot-test-report-job | sed 's/|//'| awk '{print $1}')  

echo "Info: Writing report to reports directory"

ACM_ROBOT_REPORT="$(kubectl -n $NAMESPACE logs $TEST_REPORT_POD_NAME)"

generate_report  "$ACM_ROBOT_REPORT" "report.html"

echo "Info: Reading ACM robot log from log job"

kubectl apply -n "$NAMESPACE" -f $WORKSPACE/kubernetes/eric-oss-acm-robot-test-log-job.yaml

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/acm-robot-test-log-job || true

BRIDGE_TEST_LOG_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep acm-robot-test-log-job | sed 's/|//'| awk '{print $1}')  

echo "Info: Writing log to reports directory"

ACM_ROBOT_LOG="$(kubectl -n $NAMESPACE logs $BRIDGE_TEST_LOG_POD_NAME)"

generate_report  "$ACM_ROBOT_LOG" "log.html"


echo "Info: Reading ACM robot output from output job"

kubectl apply -n "$NAMESPACE" -f $WORKSPACE/kubernetes/eric-oss-acm-robot-test-output-job.yaml

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/acm-robot-test-output-job || true

ACM_TEST_OUTPUT_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep acm-robot-test-output-job | sed 's/|//'| awk '{print $1}')  

echo "Info: Writing output to reports directory"

ACM_ROBOT_OUTPUT="$(kubectl -n $NAMESPACE logs $ACM_TEST_OUTPUT_POD_NAME)"

generate_report  "$ACM_ROBOT_OUTPUT" "output.xml"

SUCCESS=$(kubectl -n "$NAMESPACE" get job $ROBOT_TEST_JOB_NAME -o jsonpath='{.status.succeeded}')

if [[ "${SUCCESS}" == "1" ]]; then
    echo "ROBOT ACM SCIT test succesful"
  else
    echo "ROBOT ACM SCIT test unsuccesful"
    exit 1
fi
