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

WORKSPACE="${PWD}"
BUILD_DIR="${PWD}/robotbuild"
ROBOT_DOCKERFILE="${PWD}/docker"
CUSTOM_TESTPLAN_FILE=
CSIT_DIR="."

# Source libraries 
source "${PWD}/library/test-lib.sh"

POLICY_GIT_REPO="https://gerrit.onap.org/r/policy/docker"

echo "---------------------------------------------"
echo "Load Docker build env variables"
echo "---------------------------------------------"
load_build_env_vars

echo "---------------------------------------------"
echo "Building robot Policy test image"
echo "---------------------------------------------"
echo "Cloning ${POLICY_GIT_REPO}"
echo "---------------------------------------------"
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
git clone "${POLICY_GIT_REPO}"
# cp -f $WORKSPACE/testplan.txt docker/csit/clamp/plans/testplan.txt
cp -f $WORKSPACE/tests/policy-clamp-test.robot  docker/csit/resources/tests/policy-clamp-test.robot
cp -f $WORKSPACE/run-test.sh ${BUILD_DIR}/run-test.sh
cp -f $WORKSPACE/testplan.txt ${BUILD_DIR}/testplan.txt

echo "---------------------------------------------"
echo "Docker Build"
echo "---------------------------------------------"
docker build . --file $ROBOT_DOCKERFILE/Dockerfile --build-arg CSIT_DIR="$CSIT_DIR" --tag "${DOCKER_IMAGE_TAG}" --no-cache


echo "---------------------------------------------"
echo "Removing Build Direcroty"
echo "---------------------------------------------"
cd ..
rm -rf ${BUILD_DIR}


