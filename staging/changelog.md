# Staging Changelog

## 21 November 2018
* Validator v0.6.0.rc
  - Deployment config change to make validator point to the latest fastq validator image (fastq_utils:v0.1.0.rc)

* Staging Manager v0.5.3.rc
  - Remove 10s wait when creating upload area
  - Fix setting for retry policy, retrying for ~20min

* Broker v0.8.4.rc
  - Logging details
  - Added fix to ensure that import doesn't fail due to erroneous max_row count

## 19 October 2018
* State Tracker V0.7.3.rc
  - Fixed bug determining the URI for persisted state machines

* Exporter v0.7.5.rc
  - Fix bug in analysis export, analysis bundles should reference same metadata file version from input bundle

## 17 October 2018
* Broker v0.8.3.rc
  - Fixed bug whereby file metadata updates fail if a file is uploaded prior spreadsheet upload

## 16 October 2018
* Core v0.7.6.rc
  - Lazy load biomaterial dbrefs

## 15 October 2018
* Core v0.7.5.rc
  - Fix to slowdown cause by UUID generation

* State Tracking v0.7.2.rc
  - Fix to state tracking persistence
  - Ensuring envelopes go to the Cleanup state when more than the number of expected bundles are generated

## 11 October 2018
* Core v0.7.4.rc
  - Logging when submission envelope is created and submitted
  - Optimization in finding assay processes for export
  - Bug fixes

## 03 October 2018

* Broker v0.8.2.rc
  - Fix to submission error message
  
* Exporter v0.7.4.rc
  - Reverted to 20 retries spaced a minute apart for operations on the DSS API
  - Using ingest's update timestamp for creating .json files in the DSS, averting needless duplicates
  - Polling DSS Files to confirm their full creation prior to creating a bundle containing said Files

* Staging Manager v0.5.2.rc
  - Set to use HTTP HEAD when checking staging area
	
## 19 September 2018

* Core v0.7.3.rc
  - Fix bug in sending messages to state tracker when adding reference files in a secondary submission
  - Reduce timeout when sending state tracking messages
  - Updated secondary submission documentation

* State Tracker v0.7.1.rc
  - Reducing timeout before the actual submission state update happens
  - Concurrent hash map for document states

* Exporter v0.7.2.rc
  - Use latest schema for links.json

* Broker v0.8.1.rc
  - Added support for multiple ontology processing

## 12 September 2018

* Core v0.7.2.rc
  - Optimizations regarding sending of unnecessary messages to the rabbit-mq broker
  - Integration with the state tracker’s HTTP API
  - Indexing on Process resources’ input and output biomaterials/files enabling faster bundle generation and export

* State Tracker v0.7.0.rc
  - Race condition bug fix whereby state updates were processed out of order
  - Added a HTTP API for processing state update messages

* Exporter v0.7.1.rc
  - Caching of previously retrieved documents for faster export time
  - Retrying 20 times with 1 minute between for idempotent requests to the DSS

## 07 September 2018

* Accessioner v0.5.0.rc 
  - New Accessioner using Node.js

* Core v0.7.1.rc
  - Endpoint in monitoring state transitions of submission envelope
  - Added File indices in mongo for faster uploading of files metadata

* Broker v0.8.0.rc
  - Ability to upload supplementary files
  - Ability to Link entity to entity with same concrete type in the spreadsheet
  - Changes Submission report format
  - Configurable submission report
  - Error handling changes during spreadsheet upload
  - Support for additional project modules in spreadsheet

* State Tracker v0.6.1.rc
  - Optimizations in sending state tracker messages
  - Fix to race condition when processing state tracker messages

* Validator v0.6.0.rc
  - New JavaScript Validator
  - Support for Draft-07 JSON schema

* UI v0.5.2.rc
  - Fix submission dashboard pagination
