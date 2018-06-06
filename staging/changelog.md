# ingest-ui
- Added GDPR notice

# ingest-core
- Bug fix where FileMessages from staging with no dcp-type parameter in the content-type field are ignored
- Scanning a submitted envelope for bundles is asynchrononous

# ingest-broker
- moved common ingest client libs to a seperate repo; now install those libs with PyPi

# ingest-validator
- ontology validation by scanning referenced schema for referenced ontology schemas
- using a faster and more complete .fastq file validator
- no longer running 'dummy' validation jobs on non-fastq files

# ingest-accessioner
- no change

# ingest-archiver
- no change

# ingest-exporter
- timing exports to as part of scale testing
- using updated version of the hca client libraries

# ingest-state-tracking
- robustness improvements
- fixed bug where COMPLETE documents could be retracked
- fixed bug where SUBMITTED documents could re-enter VALID

# ingest-staging-manager
- no change
