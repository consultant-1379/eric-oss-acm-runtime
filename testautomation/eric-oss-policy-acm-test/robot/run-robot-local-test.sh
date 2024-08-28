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

set -o nounset
set -o errexit
set -o pipefail

# Source libraries
source "${PWD}/library/test-lib.sh"


echo "---------------------------------------------"
echo "Get all env variables"
echo "---------------------------------------------"
load_env_vars
TESTPLANDIR="${PWD}"
echo "---------------------------------------------"
echo "Cloning ${POLICY_GIT_REPO}"
echo "---------------------------------------------"
WORKSPACE="${PWD}/${TEST_DIR}"
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"
cp -f "${PWD}/testplan.txt" "$WORKSPACE"
cd "$WORKSPACE"
git clone "${POLICY_GIT_REPO}"

echo "---------------------------------------------"
echo "Exposing & Port Forwarding Policy Deployment"
echo "---------------------------------------------"
kubectl expose deployment eric-oss-acm-runtime --type=NodePort  --protocol TCP --port 80 --target-port 6969 --name="my-eric-oss-acm-runtime-exposed"  -n "$NAMESPACE"
EXPOSE_PORT=$(kubectl -n "$NAMESPACE" get svc "my-eric-oss-acm-runtime-exposed" -o jsonpath='{.spec.ports[0].nodePort}')
kubectl port-forward svc/my-eric-oss-acm-runtime-exposed --address 0.0.0.0 "$EXPOSE_PORT":80 -n "$NAMESPACE" &

echo "---------------------------------------------"
echo "Exposing & Port Forwarding Policy API Deployment"
echo "---------------------------------------------"

echo "---------------------------------------------"
echo "Setting up Python3 VENV for robot"
echo "---------------------------------------------"
ROBOT_VENV=$(mktemp -d --suffix=robot_venv)
echo "Python version is: $(python3 --version)"

python3 -m venv "${ROBOT_VENV}"
source "${ROBOT_VENV}/bin/activate"
python3 -m pip install --upgrade pip

echo "Installing Python Requirements"
# python3 -m pip install -r $WORKSPACE/cps/csit/pylibs.txt
# python3 -m pip freeze
python3 -m pip install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.5.1.*' --pre
python3 -m pip freeze

echo "---------------------------------------------"
echo "Setting up CSIT"
echo "---------------------------------------------"
ROBOT_VENV=$(mktemp -d --suffix=robot_venv)
echo "Python version is: $(python3 --version)"

# cat "${TESTPLANDIR}/testplan.txt"
cat "${TESTPLANDIR}/testplan.txt" | egrep -v '(^[[:space:]]*#|^[[:space:]]*$)' | sed "s|^|$WORKSPACE/docker/csit/clamp/tests/|" > testplan.txt
SUITES=$( xargs -a testplan.txt )


export POLICY_RUNTIME_ACM_IP="localhost"
export POLICY_API_IP="localhost"

export ROBOT_VARIABLES=
ROBOT_VARIABLES="-v POLICY_RUNTIME_ACM_IP:$POLICY_RUNTIME_ACM_IP -v POLICY_API_IP:$POLICY_API_IP -v DATADIR:$WORKSPACE/docker/csit/clamp/tests/data --exitonfailure"

TESTPLAN="${PWD}/testplan.txt"
TESTOPTIONS=

echo "Run Robot test"
echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ${SUITES} ..."
python3 -m robot.run -t CommissionAutomationCompositionV1 -N "$TESTPLAN" -v WORKSPACE:/tmp ${ROBOT_VARIABLES} $TESTOPTIONS $SUITES
