# ingest-core:v0.5.0
- Bug fix where FileMessages from staging with no dcp-type parameter in the content-type field are ignored
- Scanning a submitted envelope for bundles is asynchrononous

# ingest-broker:v0.5.1
- moved common ingest client libs to a seperate repo; now install those libs with PyPi

# ingest-validator:v0.5.0
- ontology validation by scanning referenced schema for referenced ontology schemas
- using a faster and more complete .fastq file validator
- no longer running 'dummy' validation jobs on non-fastq files
- disabled ontology validation

# ingest-accessioner:v0.4.0
- no change

# ingest-exporter:v0.5.0
- timing exports to as part of scale testing
- using updated version of the hca client libraries

# ingest-state-tracking:v0.5.0
- robustness improvements
- fixed bug where COMPLETE documents could be retracked
- fixed bug where SUBMITTED documents could re-enter VALID

# ingest-staging-manager:v0.4.0
- no change
