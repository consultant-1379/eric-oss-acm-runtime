#!/usr/bin/env sh
# ******************************************************************************
#  Copyright (C) 2024 Ericsson Software Technology
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Software Technology. The programs may be used and/or copied
# only with written permission from Ericsson Software Technology or in
# accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# ******************************************************************************

if [ "$#" -eq 1 ]; then
    CONFIG_FILE=$1
fi

if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="${POLICY_HOME}/etc/AcRuntimeParameters.yaml"
fi

echo "Policy clamp runtime acm config file: $CONFIG_FILE"

if [ -f "${POLICY_HOME}/etc/mounted/logback.xml" ]; then
    echo "overriding logback xml file"
    cp -f "${POLICY_HOME}"/etc/mounted/logback.xml "${POLICY_HOME}"/etc/
fi

$JAVA_HOME/bin/java \
    -Dlogging.config="${POLICY_HOME}/etc/logback.xml" \
    -Dcom.sun.management.jmxremote.rmi.port=9090 \
    -Dcom.sun.management.jmxremote=true \
    -Dcom.sun.management.jmxremote.port=9090 \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Dcom.sun.management.jmxremote.local.only=false \
    -Dotel.java.global-autoconfigure.enabled=true \
    -jar /app/app.jar \
    --spring.config.location="${CONFIG_FILE}"
