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
load_helm_env_var

echo "-----------------------------------------------"
echo "Deploying kubernetes CSIT test chart in cluster"
echo "-----------------------------------------------"
helm_cleanup

POLICY_APP_USER_CREDS=$(kubectl -n "$NAMESPACE" get secrets | grep policy-app-user-creds | awk '{print $1}')
POLICY_ADMIN_PASSWORD=$(kubectl -n "$NAMESPACE" get secrets "$POLICY_APP_USER_CREDS" -o jsonpath='{.data.password}' | base64 -d)

echo "Info: installing ACM CSIT test chart"
helm upgrade --install eric-oss-csit-test "$WORKSPACE/charts" \
    --set "container.env.POLICY_ADMIN_PASSWORD.value=$POLICY_ADMIN_PASSWORD" \
    --set "imageCredentials.csitTestImage.tag=$IMAGE_TAG" \
    --set "imageCredentials.readinessImage.tag=$IMAGE_TAG" \
    -n "$NAMESPACE"  --timeout 5m0s --wait || true \

ROBOT_TEST_JOB_NAME=$(kubectl -n "$NAMESPACE" get jobs | grep eric-oss-csit-test | sed 's/|//'| awk '{print $1}')

ROBOT_TEST_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep eric-oss-csit-test | sed 's/|//'| awk '{print $1}')

TEST_DESCRIBE="$(kubectl -n $NAMESPACE describe pod $ROBOT_TEST_POD_NAME)"

echo "$TEST_DESCRIBE"

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/"$ROBOT_TEST_JOB_NAME" || true

TEST_LOG="$(kubectl -n $NAMESPACE logs $ROBOT_TEST_POD_NAME)"

echo "$TEST_LOG"

echo "Info: Reading ACM robot report from log job"

kubectl -n "$NAMESPACE" wait --for=condition=complete --timeout=5m job/eric-oss-csit-log || true

TEST_REPORT_POD_NAME=$(kubectl -n "$NAMESPACE" get pods | grep eric-oss-csit-log | sed 's/|//'| awk '{print $1}')  

echo "Info: Writing report to reports directory"

ACM_ROBOT_REPORT="$(kubectl -n $NAMESPACE logs $TEST_REPORT_POD_NAME eric-oss-csit-report)"

generate_report  "$ACM_ROBOT_REPORT" "report.html"

echo "Info: Writing log to reports directory"

ACM_ROBOT_LOG="$(kubectl -n $NAMESPACE logs $TEST_REPORT_POD_NAME eric-oss-csit-log)"

generate_report  "$ACM_ROBOT_LOG" "log.html"

echo "Info: Writing output to reports directory"

ACM_ROBOT_OUTPUT="$(kubectl -n $NAMESPACE logs $TEST_REPORT_POD_NAME eric-oss-csit-output)"

generate_report  "$ACM_ROBOT_OUTPUT" "output.xml"

SUCCESS=$(kubectl -n "$NAMESPACE" get job $ROBOT_TEST_JOB_NAME -o jsonpath='{.status.succeeded}')

if [[ "${SUCCESS}" == "1" ]]; then
    echo "Robot csit test succesful"
  else
    echo "Robot csit test unsuccesful"
    exit 1
fi