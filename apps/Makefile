deployment-stage = ${DEPLOYMENT_STAGE}
force-refresh-pods = ${FORCE_REFRESH_PODS}
ingest-accessioner = ${INGEST_ACCESSIONER_VERSION}
ingest-broker = ${INGEST_BROKER_VERSION}
ingest-core = ${INGEST_CORE_VERSION}
ingest-exporter = ${INGEST_EXPORTER_VERSION}
ingest-ontology = ${INGEST_ONTOLOGY_VERSION}
ingest-staging-manager = ${INGEST_STAGING_MANAGER_VERSION}
ingest-state-tracking=${INGEST_STATE_TRACKING_VERSION}
ingest-validator=${INGEST_VALIDATOR_VERSION}

deploy-app-%:
	# Handler failure of deletion if app not deployed yet here
	@if [ $(force-refresh-pods) == TRUE ]; then helm delete $(*); fi;
	helm package $(*)
	. ../config/environment_$(deployment-stage) && helm upgrade $(*) $(*)  --set environment=$(deployment-stage),image=$($(*)) --force --install
	rm *.tgz
