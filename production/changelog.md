# Production Changelog

## 15 May 2019 (hotfix)
* Exporter v0.8.1:6bb5cd5
- Ignore failed processes trying to create duplicate bundles

## 30 April 2019
* Validator v0.6.4:39e6120 (hotfix)
- Only perform file validation if the the File metadata document is valid

## 16 Apr 2019

* UI 2c7bfd3:v0.9.1
 - Presenting all validation errors

## 19 March 2019

* Validator v0.6.0
- Typescript
- Fixed bug where Files would be stuck in validating if metadata was missing(i.e files uploaded before complete spreadsheet import)
- Asserting that Files aren't already validating before requesting file-validation
- No longer triggering file-validation if a validation job has already been completed for the same checksums

* Core v0.8.5
- Added ValidationJobs to track running/completed file-validation jobs
- Bug fix attempting to parse property migration files from the Schemas bucket

* Ingress
- Using HTTP->HTTPS redirection 

## 12 March 2019

* Broker v0.8.8 
  - minor fix to code
* Core  v0.8.4
  - authentication related security related patches

## 06 March 2019

* UI 4f3615c:v0.5.5 (hotfix)
  - Fix production configuration
  - Fix compilation errors for prod build due to Angular version upgrade

## 05 March 2019

* Broker 37e15b8:v0.8.7
  - Bug fixes in the importer: trailing space and number field conversion

* UI 987aaf7:v0.5.4
  - Show linking progress in the UI
  - Upgrade to component versions

## 20 February 2019

* Core v0.8.3
  - Added submission envelope field to track number of expected links/edges in the metadata graph
  - Hotfix to use different environment variables for user and service JWTs

* Broker v0.8.6
  - Utilizing submission envelope's link/edge counter

## 12 February 2019
* Broker v0.8.5
  - Reporting all import errors to the submission envelope

* Core v0.8.1
  - Bug fixes in JSON parsing upload-service messages
  - Logging auth failures

## 29 January 2019
* Core v0.8.0
  - Expose API endpoints for rabbitmq communication
  - Accept and verify JWT tokens from DCP Auth and GCP Service accounts
  - Point to schema https urls

* Exporter v0.7.7
  - Reporting export errors in submission envelope
  - Remove unused schema env var in the exporter

* UI v0.5.3
  - Use DCP Auth (Fusillade) for Authentication
  - Display submission errors
  - Display commit hash build


## 08 January 2019

* Exporter v0.7.6
  - Fix to DSS datetime version format
  - DSS API Authentication
  - More info on logs
  - Deploy new exporter secrets


## 18 December 2018
* Broker v0.8.4
  - Fix to connection reset error during spreadsheet import
  - Fix schema parsing, defaults to string if there is no items obj inside array field in schema
  - Added fix to ensure that import doesn't fail due to erroneous max_row count
  - Fixes to raising and logging error details

* Validator v0.6.0 (same version)
  - Config change: Point to the latest fastq validator image (fastq_utils:v0.1.0.rc) when requesting fastq validation jobs from the upload validation service

* Staging Manager v0.5.3
  - Remove 10s wait when creating upload area
Fix setting for retry policy, retrying for ~20min

* State-tracking v0.7.4
  - Addressed bug where a deleted state machine would be stored as null in the Redis database

* Ontology
  - Redeploying to pick up new ontology values


## 29 October 2018
* Core v0.7.7
  - Use indexing when finding files by UUID

## 23 October 2018

* State Tracker v0.7.3
  - Fixed bug determining the URI for persisted state machines
  - Fix to state tracking persistence
  - Ensuring envelopes go to the Cleanup state when more than the number of expected bundles are generated

* Exporter v0.7.5
  - Fix bug in analysis export, analysis bundles should reference same metadata file version from input bunlde
  - Reverted to 20 retries spaced a minute apart for operations on the DSS API
  - Using ingest's update timestamp for creating .json files in the DSS, averting needless duplicates
  - Polling DSS Files to confirm their full creation prior to creating a bundle containing said Files

* Broker v0.8.3
  - Fixed bug whereby file metadata updates fail if a file is uploaded prior spreadsheet upload
  - Fix to submission error message

* Core v0.7.6
  - Lazy load biomaterial dbrefs
  - Logging when submission envelope is created and submitted
  - Optimization in finding assay processes for export
  - Fix to slowdown cause by UUID generation
  - Bug fixes

* Staging Manager v0.5.2
  - Set to use HTTP HEAD when checking staging area


## 25 September 2018
* Core v0.7.3
  - Fix bug in sending messages to state tracker when adding reference files in a secondary submission
  - Reduce timeout when sending state tracking messages
  - Updated secondary submission documentation

* State Tracker v0.7.1
  - Reducing timeout before the actual submission state update happens
  - Concurrent hash map for document states

* Exporter v0.7.2
  - Use latest schema for links.json

* Broker v0.8.1
  - Added support for multiple ontology processing
	
## 18 September 2018

* Core v0.7.2
  - Optimizations regarding sending of unnecessary messages to the rabbit-mq broker
  - Integration with the state tracker’s HTTP API
  - Indexing on Process resources’ input and output biomaterials/files enabling faster bundle generation and export
  - Endpoint in monitoring state transitions of submission envelope
  - Added File indices in mongo for faster uploading of files metadata
  - Fixed bug when adding input bundle manifests for restructured bundles to processes
  - Added Submission Error entity and endpoints
  - State tracker optimizations
  - Core messaging optimizations
  - Added DRAFT transition controller methods for each metadata resource
  - Fixed schemas endpoint to correctly fetch latest schema
  - Addressed concurrency issues when sending messages in the core
  - Modified schema parser to use URI directly.
  - Set script to assemble package when running locally
  - Added SCHEMA_BASE_URI in docker compose script
  - Added triggersAnalysis flag in submission envelope
  - Replaced embedded web server to improve stability
  - Point schema url to s3 bucket url to get the xml file
  - Replaced embedded Tomcat server with Jetty
  - Set up to enable performance testing

* State Tracking v0.7.0
  - Race condition bug fix whereby state updates were processed out of order
  - Added a HTTP API for processing state update messages
  - Optimizations in sending state tracker messages
  - Fix to race condition when processing state tracker messages

* Exporter v0.7.1
  - Caching of previously retrieved documents for faster export time
  - Retrying 20 times with 1 minute between for idempotent requests to the DSS

* Accessioner v0.5.0
  - New Accessioner using Node.js

* Broker v0.8.0
  - Ability to upload supplementary files
  - Ability to Link entity to entity with same concrete type in the spreadsheet
  - Changes Submission report format
  - Configurable submission report
  - Error handling changes during spreadsheet upload
  - Support for additional project modules in spreadsheet
  - Handling schema /system links during spreadsheet upload
  - Upgraded dependencies for hca-ingest module
  - Fix bug in Schema template api to point to correct schema environment

* Validator v0.6.0
  - New JavaScript Validator
  - Support for Draft-07 JSON schema

* Staging Manager v0.5.1
  - Now waits for  for Ingest Core to come online before consuming messages

* Exporter v0.7.1
  - Using latest version of input data files in secondary bundle export
  - Bundles now contain supplementary files
  - Using latest version of links.json schema
  - Respecting the “triggerAnalysis” flag on envelopes to toggle triggering of analysis on primary submissions
  - Bundle restructure
  - Fixed bug when fetching documents from ingest-core
  - Remove hca dependency on the exporter listener and use the ingest-client version which uses hca v0.5

* UI v0.5.2
  - Fix submission dashboard pagination
