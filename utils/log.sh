#!/usr/bin/env bash

if [ -z $1 ]; then
    echo 'No deployment name provided.'
    exit 1
fi

deployment=$1
echo "INFO: Generating logs for deployment [${deployment}] in [${DEPLOYMENT_STAGE}]..."

log_dir=../_local/logs/${DEPLOYMENT_STAGE}
mkdir -p ${log_dir}

for pod in $(kubectl get pods -l app=${deployment} -o name | sed 's/pod\///g'); do
    file_name=${log_dir}/$(date '+%Y-%m-%d_%H:%M:%S')_${pod}.log
    kubectl logs $pod > ${file_name}
    echo "${file_name}"
done
