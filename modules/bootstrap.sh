#!/bin/bash

# NOTE: Execute this scirpt from Basiton/trusted admin host ONLY.

# Run: *** bash bootstrap.sh environment region ***
# Example: bash bootstrap.sh dev us-west-2

# *** This scripts generate random RDS MySQL DB Admin password \
#    and uploads the new password to local parameter store ***

# Prameter store path set by this script: /environment/region/<NAME>

if [[ $# -eq 0 ]] ; then
    echo "Usage: bootstrap.sh ENV LOCATION"
    echo "ERROR: The script needs to be invoked with a environment name, i.e. dev or test or prod"
    exit 1
fi

ENV=$1
LOCATION=$2

mysql_dbadmin_password=`python -c "import random;import string; print(''.join(random.choice(string.ascii_letters + string.digits) for i in range(20)));"`

aws ssm put-parameter --name /${ENV}/${LOCATION}/dbadmin_password --type "SecureString" --value $mysql_dbadmin_password
