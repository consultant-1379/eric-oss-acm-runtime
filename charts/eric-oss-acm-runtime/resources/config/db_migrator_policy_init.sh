# ******************************************************************************
#  Copyright (C) 2022-2024 Ericsson Software Technology
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Software Technology. The programs may be used and/or copied
# only with written permission from Ericsson Software Technology or in
# accordance with the terms and conditions stipulated in the
# agreement/contract under which the program(s) have been supplied.
# ******************************************************************************

#!/bin/sh
/opt/app/policy/bin/prepare_upgrade.sh ${SQL_DB}
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o upgrade
rc=$?
/opt/app/policy/bin/db-migrator-pg -s ${SQL_DB} -o report
exit $rc
