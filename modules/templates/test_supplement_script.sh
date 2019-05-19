#!/bin/bash

# *** TEST SCRIPT ONLY ***

# NOTE: Run this script ONLY to test from your MAC/Linux system.
# Use the same environemt and region used for setting Parameter store

# Run: *** bash test_supplement_script.sh environment region ***
# Example: bash test_supplement_script.sh dev us-west-2 

# ** This scripts fetches MySql DB Admin Password from Parameter store **

pip install pip==18.1
pip install requests
pip install markdown

parameter_store_path="/$1/$2"
region=$2

echo "Fetching secrets - MySql DB Admin Password from Parameter store"
app_mysql_db_password=`aws ssm get-parameter --name "${parameter_store_path}/dbadmin_password" --with-decryption --output text --region "${region}"| awk '{split($0,array,"\t")} END{print array[6]}'`

# setup mysql db file with vars needed by application
mkdir -p $PWD/auto
echo "{
\"app_mysql_db_password\" : \"${app_mysql_db_password}\",
}" > $PWD/auto/app_db.json
