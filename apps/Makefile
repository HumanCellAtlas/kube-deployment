deployment-stage = ${DEPLOYMENT_STAGE}
ingest-accessioner = ${INGEST_ACCESSIONER_VERSION}
ingest-broker = ${INGEST_BROKER_VERSION}
ingest-core = ${INGEST_CORE_VERSION}
ingest-exporter = ${INGEST_EXPORTER_VERSION}
ingest-ontology = ${INGEST_ONTOLOGY_VERSION}
ingest-staging-manager = ${INGEST_STAGING_MANAGER_VERSION}
ingest-state-tracking=${INGEST_STATE_TRACKING_VERSION}
ingest-validator=${INGEST_VALIDATOR_VERSION}

deploy-app-%:
	helm package $(*)
	#call to github api, pass this in to deploy if its a branch (ie force deploy)
	. ../config/environment_$(deployment-stage) && helm upgrade $(*) $(*)  --set environment=$(deployment-stage),image=$($(*)) --force --install
	rm *.tgz

deploy-secrets:
	. ../config/environment_$(deployment-stage) && helm upgrade secrets secrets  --set environment=$(deployment-stage) --force --install

deploy-apps:
	$(MAKE) deploy-app-ingest-core
	$(MAKE) deploy-app-ingest-accessioner
	$(MAKE) deploy-app-ingest-broker
	$(MAKE) deploy-app-ingest-exporter
	$(MAKE) deploy-app-ingest-ontology
	$(MAKE) deploy-app-ingest-staging-manager
	$(MAKE) deploy-app-ingest-state-tracking
	$(MAKE) deploy-app-ingest-validator
	# $(MAKE) deploy-ingest-auth

deploy-all:
	$(MAKE) deploy-secrets
	$(MAKE) deploy-apps
