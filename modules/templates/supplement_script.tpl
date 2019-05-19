#!/usr/bin/bash

# NOTE: Run this script on AWS Linux Server which connects to RDS MySQL.

# ** This scripts fetches MySql DB Admin Password from Parameter store **

pip uninstall -y markupsafe
pip uninstall -y markdown
pip uninstall -y requests
pip uninstall -y urllib3

pip install pip==18.1
pip install requests
pip install markdown
pip install markupsafe

echo "Fetching secrets - MySql DB Admin Password from Parameter store"
app_mysql_db_password=`aws ssm get-parameter --name "${parameter_store_path}/dbadmin_password" --with-decryption --output text --region "${region}"| awk '{split($0,array,"\t")} END{print array[6]}'`

# setup mysql db file with vars needed by application
mkdir -p /var/auto/app
echo "{
\"app_mysql_db_identifier\" : \"${app_mysql_db_identifier}\",
\"app_mysql_db_username\" : \"${app_mysql_db_username}\",
\"app_mysql_db_port\" : \"${app_mysql_db_port}\",
\"app_mysql_db_name\" : \"${app_mysql_db_name}\",
\"app_mysql_db_password\" : \"${app_mysql_db_password}\",
}" > /var/auto/app/app_db.json
