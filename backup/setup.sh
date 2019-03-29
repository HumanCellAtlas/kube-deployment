#!/usr/bin/env bash

if [ -z $DEPLOYMENT_STAGE ]; then
    echo "Unspecified DEPLOYMENT_STAGE env variable."
    exit 1
else
    echo "INFO: using deployment stage [${DEPLOYMENT_STAGE}]"
fi

if [ -z $1  ]; then
    echo "No AWS credentials file specified."
    exit 1
fi

IFS="," 
read -ra credentials <<< $(awk  -v RS='\r\n' -F "," 'NR==2' $1)

access_key=$(echo ${credentials[0]} | tr -d '\n' | openssl base64)
secret_access_key=$(echo ${credentials[1]} | tr -d '\n' | openssl base64)

helm upgrade --wait --install -f config/${DEPLOYMENT_STAGE}.yaml --set secret.aws.accessKey=${access_key},secret.aws.secretAccessKey=${secret_access_key} ingest-backup backup






