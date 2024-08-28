#!/usr/bin/env sh
# ******************************************************************************
#  Copyright (C) 2023 Ericsson Software Technology
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Software Technology. The programs may be used and/or copied
# only with written permission from Ericsson Software Technology or in
# accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# ******************************************************************************

set -e

PROCESSED=false
WORKDIR=/workdir

for i in $(ls $WORKDIR); do
  echo "Processing $i ...."

  envsubst < $WORKDIR/$i > /processed/$i
  PROCESSED=true
done

ls /processed/

if [ ! $PROCESSED = true ]
then
  echo 'No files processed'
  exit 1
fi