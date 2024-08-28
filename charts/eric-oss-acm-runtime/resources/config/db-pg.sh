#!/bin/sh
# ******************************************************************************
#  Copyright (C) 2022-2024 Ericsson Software Technology
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Software Technology. The programs may be used and/or copied
# only with written permission from Ericsson Software Technology or in
# accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# ******************************************************************************

if $TLS_ENABLED;
then
  psql -h ${PG_HOST} -p ${PG_PORT} -U postgres --command "CREATE USER ${PG_USER}"
else
  export PGPASSWORD=${PG_ROOT_PASSWORD};
  psql -h ${PG_HOST} -p ${PG_PORT} -U postgres --command "CREATE USER ${PG_USER} WITH PASSWORD '${PG_USER_PASSWORD}'"
fi

for db in migration pooling clampacm operationshistory
do
    psql -h ${PG_HOST} -p ${PG_PORT} -U postgres --command "CREATE DATABASE ${db};"
    psql -h ${PG_HOST} -p ${PG_PORT} -U postgres --command "GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${PG_USER};"
done