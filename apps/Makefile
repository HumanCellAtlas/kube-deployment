SHELL!=which bash
deployment-stage = ${DEPLOYMENT_STAGE}
force-refresh = ${FORCE_REFRESH}
ingest-accessioner = ${INGEST_ACCESSIONER_REF}
ingest-node-accessioner = ${INGEST_NODE_ACCESSIONER_REF}
ingest-broker = ${INGEST_BROKER_REF}
ingest-core = ${INGEST_CORE_REF}
ingest-exporter = ${INGEST_EXPORTER_REF}
ontology = ${ONTOLOGY_REF}
ingest-staging-manager = ${INGEST_STAGING_MANAGER_REF}
ingest-state-tracking= ${INGEST_STATE_TRACKING_REF}
ingest-validator = ${INGEST_VALIDATOR_REF}

fastq-validator-image = ${FASTQ_VALIDATOR_IMAGE}

deploy-app-%:
	$(MAKE) set-context
	helm package $(*)
	@if [ "$(force-refresh)" == TRUE ]; then kubectl delete deployment $(*) --ignore-not-found=true; fi;
	. ../config/environment_$(deployment-stage) && helm upgrade -f ./values.yaml -f $(deployment-stage).yaml $(*) $(*)  --set-string environment=$(deployment-stage),fastqImage=$(fastq-validator-image),image=$($(*)) --force --recreate-pods --wait --install
	rm *.tgz

deploy-secrets:
	$(MAKE) set-context
	# retrieve secrets from aws secrets manager
	. ../config/environment_$(deployment-stage) && helm upgrade secrets secrets  --set environment=$(deployment-stage) --force --install

deploy-all-apps:
	$(MAKE) set-context
	$(MAKE) deploy-app-ingest-state-tracking
	$(MAKE) deploy-app-ingest-broker
	$(MAKE) deploy-app-ingest-core
	$(MAKE) deploy-app-ingest-node-accessioner
	$(MAKE) deploy-app-ingest-exporter
	$(MAKE) deploy-app-ingest-staging-manager
	$(MAKE) deploy-app-ingest-validator
	$(MAKE) deploy-app-ontology

deploy-all:
	$(MAKE) set-context
	$(MAKE) deploy-secrets
	$(MAKE) deploy-all-apps

set-context:
	kubectx ingest-eks-$(deployment-stage)
	kubens $(deployment-stage)-environment
