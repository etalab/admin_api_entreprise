#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Usage: $0 /path/to/ansible/scripts"
fi

path=$1

cd $path

production_key=`ansible-vault view secrets/admin_apientreprise_secrets_production.yml | grep MASTER_KEY | awk '{print $2}'`
staging_key=`ansible-vault view secrets/admin_apientreprise_secrets_staging.yml | grep MASTER_KEY | awk '{print $2}'`
sandbox_key=`ansible-vault view secrets/admin_apientreprise_secrets_sandbox.yml | grep MASTER_KEY | awk '{print $2}'`

cd -

echo $production_key > config/credentials/production.key
echo $staging_key > config/credentials/staging.key
echo $sandbox_key > config/credentials/sandbox.key
