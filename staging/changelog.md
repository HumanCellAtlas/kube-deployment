# Staging Changelog
## 29 July 2019

* Broker v0.9.2.rc: e650e6f
- Fix reporting of submission error

* Core v0.9.3.rc: 487b1cf
- Fix failure in POSTing submission endpoint

* UI v0.9.7.rc: 8f5010e
- Removing button to do retry when metadata is invalid

* Exporter v0.8.7.rc: 5388780
- Reinstantiate DSS client to prevent token expiration

## 24 July 2019
* Core v0.9.2.rc
- Put back authentication for PUT & PATCH requests

* Mongo
- Set a size limit on in-memory caching to ensure cluster reliability

### Deployment Notes:
1. Redeploy the mongo helm chart:
  * `cd infra && make install-infra-helm-chart-mongo`


## 17 July 2019
* Exporter v0.8.6.rc: c195f09
- Fix date format check
* Validator v0.6.5.rc: 599b12c
- (same version) fastq subprocess fix
* Broker v0.9.1.rc: eb4393a
- Fix updating of file metadata when data file is uploaded first

## 15 July 2019
* Core v0.9.2.rc: 9b7a381
- APIs for performing simple updates to bundles
- APIs for viewing JSONPatch diffs when performing updates
- Search submissions by project
- Disabled “Submit” button when linking hasn’t yet been completed(spreadsheet submissions only)
- Now using Java 11, Spring boot 2

* Exporter v0.8.5.rc: 41387a7
- Handles update submissions and performs simple bundle updates as necessary
- Separate AMQP listener for update messages
- duplicate links in links.json fix

* Broker v0.9.0.rc: 0d85bbf
- Handles update spreadsheets
- Providing a mechanism for generating and downloading update-spreadsheets from submitted spreadsheets

* UI v0.9.6.rc: 4d58809
- Widgets for uploading and downloading an update-spreadsheet
- Paginated project dashboard
- Widget to search for projects by title, shortname, etc.
- Submissions table view inside the projects tab

* Validator v0.6.5.rc: 599b12c
- Added ontology validation keyword
- Ontology service updates

* Staging manager v0.5.4.rc: 7791e6c
- ingest-client library updates, refactoring

* State tracker v0.7.5.rc: 38a399c
- Now using Java 11

### Deployment Notes:
1. Delete deployment of ingest-node-accessioner
2. Deploy persistence volume claim before redeploying ingest-broker
  * `make setup-retained-storage-staging`
  * `helm delete ingest-broker`
2. Redeploy core after state tracker
3. Redeploy validator after ontology service
4. Update mongo database:
* Need to apply these changes so that the latest codes will work for existing documents. It is important that the queries are executed one at a time and monitor the RAM usage of mongo during execution using top. If the RES value in top output is reaching 4-5gb, restart the mongo pod (`kubectl delete pod mongo-0`) to reset the RES value to minimum value.

```
// optional

db.project.find({ "isUpdate": null }).count()

db.biomaterial.find({ "isUpdate": null }).count()

db.protocol.find({ "isUpdate": null }).count()

db.process.find({ "isUpdate": null }).count()

db.file.find({ "isUpdate": null }).count()

//
db.project.update(
    { "isUpdate": null }, 
    { "$set": { "isUpdate": false } }, false, true
)

db.biomaterial.update(
    { "isUpdate": null }, 
    { "$set": { "isUpdate": false } }, false, true
)

db.process.update(
    { "isUpdate": null }, 
    { "$set": { "isUpdate": false } }, false, true
)

db.file.update(
    { "isUpdate": null }, 
    { "$set": { "isUpdate": false } }, false, true
)

db.protocol.update(
    { "isUpdate": null }, 
    { "$set": { "isUpdate": false } }, false, true
)

```

## 07 June 2019
* Core v0.9.1.rc:f17bc84
- New endpoints for searching primary and analysis bundle manifests

## 05 Jun 2019
* Exporter v0.8.3.rc:be11bc4
- Fix submissions stuck in Processing due to failed state tracker bundle complete notification

* UI v0.9.5.rc:bb98f1c
- Make Fusillade url configurable thru env var
- Fix greetings and picture display

## 29 May 2019
* Exporter 0.8.2.rc
- Minor changes to prevent creation of Pika connections unncessarily.

## 22 May 2019
* Exporter v0.8.1.rc:6bb5cd5
- Do not inform user when there’s a failure creating a duplicate bundle

* UI v0.9.4.rc:f00e018
- Use Fusillade integration

## 30 April 2019
* Validator v0.6.4.rc:39e6120 (hotfix)
- Only perform file validation if the the File metadata document is valid

## 20 March 2019
* Core v0.8.5.rc
- Exclude property_migrations file when retrieving latest schemas from s3 bucket listing
- Log INFO messages
- Fix intermittent issue where file validation fails due to many validation events
- Find by validation ID using the ID of the validation job
- Always setting to DRAFT when updating a file's cloudUrl/checksums

* Validator v0.6.2.rc
- Bug fix validating files which do not trigger job
- Handling errors
- Added checking of checksum when triggering validation job
- Added methods in ingest-client for fetching file checksum info
- Bug fix when refusing to validate File resources with no content/metadata
- Security patches
- Targetting a newer version of the fastq validation image

## 13 March 2019

* Core 3bd05d0:v0.8.5.rc
  - Exclude property_migrations file when retrieving latest schemas from s3 bucket listing
  - Log INFO messages
  - Fix intermittent issue where file validation fails due to many validation events
  - Find by validation ID using the ID of the validation job
  - Always setting to DRAFT when updating a file's cloudUrl/checksums

* Validator f512fd8:v0.6.1.rc
  - Bug fix validating files which do not trigger job
  - Handling errors
  - Added checking of checksum when triggering validation job
  - Added methods in ingest-client for fetching file checksum info
  - Bug fix when refusing to validate File resources with no content/metadata
  - Security patches
  - Targetting a newer version of the fastq validation image

* Ingress
  - Redeploy to enable http -> https redirects to Ingest endpoints

* RabbitMQ
  - Redeploy to restrict access

* Mongo
  - Delete validationId index in File collection `db.file.dropIndex("validationId")`

## 06 March 2019

* Broker 704e5a7:v0.8.8.rc 
  - minor fix to code
* Core f7e85be:v0.8.4.rc
  - authentication related security related patches


## 21 February 2019

* Broker 37e15b8:v0.8.7.rc
  - Bug fixes in the importer: trailing space and number field conversion

* UI c074e10:v0.5.4.rc
  - Show linking progress in the UI
  - Upgrade to component versions


## 13 February 2019

* Core v0.8.2.rc
  - Added submission envelope field to track number of expected links/edges in the metadata graph

* Broker v0.8.6.rc
  - Utilizing submission envelope's link/edge counter

## 30 January 2019

* Broker v0.8.5.rc
  - Reporting all import errors to the submission envelope

* Core v0.8.1.rc
  - Bug fixes in JSON parsing upload-service messages
  - Logging auth failures

## 23 January 2019

* Core v0.8.0.rc
  - Expose API endpoints for rabbitmq communication
  - Accept and verify JWT tokens from DCP Auth and GCP Service accounts
  - Point to schema https urls

* Exporter v0.7.7.rc
  - Reporting export errors in submission envelope
  - Remove unused schema env var in the exporter

* Ontology
  - Redeploying to pick up new ontology values

* UI v0.5.3.rc
  - Use DCP Auth (Fusillade) for Authentication
  - Display submission errors
  - Display commit hash build

## 12 December 2018

* Broker v0.8.4.rc
  - Fix to connection reset error during spreadsheet import
  - Fix schema parsing, defaults to string if there is no items obj inside array field in schema
  - Added fix to ensure that import doesn't fail due to erroneous max_row count
  - Fixes to raising and logging error details

* Exporter v0.7.6.rc
  - Fix to DSS datetime version format
  - DSS API Authentication
  - More info on logs
  - Deploy new exporter secrets

* Validator v0.6.0.rc (same version)
  - Deployment config change to make validator point to the latest fastq validator image (fastq_utils:v0.1.0.rc)

* Staging Manager v0.5.3.rc
  - Remove 10s wait when creating upload area
  - Fix setting for retry policy, retrying for ~20min

* Ontology
  - Redeploying to pick up new ontology values

## 24 October 2018

* Core v0.7.7.rc
  - simplified findByUuid

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
