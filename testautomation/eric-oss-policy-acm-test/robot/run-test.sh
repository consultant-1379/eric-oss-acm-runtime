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

set +e
set +o pipefail

cat "${PWD}/testplan.txt" | egrep -v '(^[[:space:]]*#|^[[:space:]]*$)' | sed "s|^|${PWD}/docker/csit/resources/tests/|" > testplanexe.txt
SUITES=$( xargs -a testplanexe.txt )

export POLICY_RUNTIME_ACM_TEST_CASE=${POLICY_RUNTIME_ACM_TEST_CASE}
export POLICY_RUNTIME_ACM_IP=${POLICY_RUNTIME_ACM_IP}
export POLICY_ADMIN_PASSWORD=${POLICY_ADMIN_PASSWORD}

export ROBOT_VARIABLES=
ROBOT_VARIABLES="-v POLICY_RUNTIME_ACM_IP:$POLICY_RUNTIME_ACM_IP -v POLICY_ADMIN_PASSWORD:$POLICY_ADMIN_PASSWORD"

TESTPLAN="${PWD}/testplan.txt"
TESTOPTIONS=

echo "Run Robot test"
echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ${SUITES} ..."
python3 -m robot.run -t $POLICY_RUNTIME_ACM_TEST_CASE  -N "$TESTPLAN" -v WORKSPACE:/tmp ${ROBOT_VARIABLES} $TESTOPTIONS $SUITES
RESULT=$?
echo "RESULT: ${RESULT}"
cp -rf . /tmp
exit ${RESULT}