# Ingest Service Deployment

Deployment setup for the Ingestion Service on  [Kubernetes](https://kubernetes.io/) clusters.

## Set up local environment
### Mac
1. `git clone https://github.com/HumanCellAtlas/ingest-kube-deployment.git`
2. Install [terraform](https://www.terraform.io/intro/getting-started/install.html): `brew install terraform`.
3. [Ensure your pip is running on python 3](https://opensource.com/article/19/5/python-3-default-mac).
3. Install [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html): `pip install awscli`.
4. Install [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html): `brew install aws-iam-authenticator`
5. Install kubectl: `brew install kubernetes-cli`
6. Install kubectx (kubens included): `brew install kubectx`
7. Install [helm](https://github.com/kubernetes/helm): `brew install kubernetes-helm`
8. Install [jq](https://stedolan.github.io/jq/) `brew install jq`

### Ubuntu
1. `git clone https://github.com/HumanCellAtlas/ingest-kube-deployment.git`
2. Install terraform with the [terraform instructions](https://learn.hashicorp.com/terraform/getting-started/install.html).
  - If you install with `sudo snap install terraform` you may run into the error `Error configuring the backend "s3": NoCredentialProviders: no valid providers in chain. Deprecated.`
3. Install [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html): `pip install awscli`.
4. Install [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
5. Install kubectl: `sudo snap install kubectl --classic`
6. Install [kubectx and kubens](https://github.com/ahmetb/kubectx).
7. Install helm: `sudo snap install helm --classic`
8. Install [jq](https://stedolan.github.io/jq), if required. `sudo apt-get install jq`

## Configuring AWS connection
1. `aws configure set default.region us-east-1`
1. `aws configure set default.output json`
1. `aws configure --profile hca-id`
	- See [Quickly Configure ASW CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration) for `AWS Access Key ID` & `AWS Secret Access Key`
1. See [this video](https://org-humancellatlas-sam.s3.amazonaws.com/HCA-prod-acct-setup-720p.mov) for configuring your connection to the DCP Developer Role.
 - Account: `humancellatlas`
 - Role: `dcp-developer`
 - ARN: `arn:aws:iam::861229788715:role/dcp-developer`


## Access/Create/Modify/Destroy EKS Clusters

### Access existing ingest eks cluster (aws)
These steps assumes you have the correct aws credentials and local environment tools set up correctly. This only has to be run one time.
1. `source config/environment_ENVNAME` where ENVNAME is the name of the environment you are trying to access
2. `cd infra`
3. `make retrieve-kubeconfig-ENVNAME` where ENVNAME is the name of the environment you are trying to access
 - To resolve `error: unable to recognize "dev/namespace.yaml": Get <...>: getting credentials: exec: exec: "heptio-authenticator-aws": executable file not found in $PATH`
 - Edit `~/.kube/config`, Replace `heptio-authenticator-aws` with `aws-iam-authenticator`.
4. `kubectl`, `kubens`, `kubectx`, and `helm` will now be tied to the cluster you have sourced in the step above.

### How to access dashboard
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
1. `kubectx ingest-eks-ENVNAME` where ENVNAME is the name of the cluster environment you are trying to access
2. Generate token:
	`kubectl -n kube-system describe secrets/$(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`
3. Start the proxy:
	`kubectl proxy`
4. Browse to the dashboard endpoint at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
5. Choose Token and paste token from step 2 above

### Create new ingest eks cluster (aws)
These steps assumes you have the correct aws credentials and local environment tools set up correctly.
These steps will set up a new ingest environment from scratch via terraform and will also apply all kubernetes monitoring and dashboard configs, RBAC role and aws auth setup.
1. `cp config/environment_template config/environment_ENVNAME` where envname should reflect the name of the environment you are trying to create.
2. Replace all values marked as 'PROVIDE...' with the appropriate value
3. Ensure the aws profile name in this config is mapped to the name of the aws profile in your ~/.aws/config or ~/.aws/credentials/ path that has admin access to the relevant aws account.
4. Ensure the VPC IP in this config file is a valid and unique VPC IP value.
5. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment in the config file you created above
6. `cd infra`
7. `make create-cluster-ENVNAME` where ENVNAME is the name of the environment you are trying to create. This step will also deploy the backend services (mongo, redis, rabbit)
8. Follow the steps to access the kubernetes dashboard. Once you see one active tiller pod in the environment namespace, continue to the next step.
9. Follow instructions below to deploy applications.

### Modify and deploy updated EKS and AWS infrastructure
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
1. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment you are trying to modify.
2. Update infra/eks.tf as desired.
2. `cd infra`
3. `make modify-cluster-ENVNAME` where ENVNAME reflects the name of the environment you are trying to modify.

### Destroy ingest eks cluster (aws)
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
These steps will bring down the entire infrastructure and all the resources for your ingest kubernetes cluster and environment. This goes all the way up to the VPC that was created for this environment's cluster.
1. Follow setups 2-5 in 'Create new ingest eks cluster (aws)' if config/environment_ENVNAME does not exist where ENVNAME is the environment you are trying to destroy
2. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment in the config file you created above
3. `cd infra`
4. `make destroy-cluster-ENVNAME` where ENVNAME is the name of the environment you are trying to destroy
*Note*: The system could encounter an error (most likely a timeout) during the destroy operation. Failing to remove some resources such as the VPC, network interfaces, etc. can be tolerated if the ultimate goal is to rebuild the cluster. In the case VPC, for example, the EKS cluster will just reuse it once recreated.

#### Reusing Undeleted Network Components

The Terraform manifest declares some network components like the VPC and subnets, that for some reason refuse to get delete during the destroy operation. This operation needs some work to improve, but at the meantime, a workaround is suggested below.

*Force the subnet declarations to use the existent ones* by overriding the `cidr_block` attribute of the `aws_subnet.ingest_eks` resource. To see the undeleted subnet components, use `terraform show`.

For example, in dev, the CIDR is set to `10.40.0.0/16`. The Terraform manifest at the time of writing makes computations with this on build time that often results in 2 subnets `10.40.0.0/24` and `10.40.1.0/24` that could refuse deletion. To make the Terraform build reuse these components, the `cidr_block` attribute under the `aws_subnet` resource can be set to the following:

    cidr_block        = "10.40.${count.index}.0/24"


## Install and Upgrade Core Ingest Backend Services (mongo, redis, rabbit)

### Install backend services (mongo, redis, rabbit)
1. `cd infra`
2. `make deploy-backend-services-ENVNAME` where ENVNAME is the name of the environment you are trying to create.

## Upgrade backend services (mongo, redis, rabbit)
Coming soon

## Deploy and Upgrade Ingest Applications

### Deploy one kubernetes dockerized applications to an environment (aws)
1. Make sure you have followed the instructions above to create or access an existing eks cluster
2. Change the branch or tag in `config/environment_ENVNAME` if needed where ENVNAME is the environment you are deploying to.
3. `cd apps`
4. `make deploy-app-APPNAME` where APPNAME is the name of the ingest application. For example, `make deploy-app-ingest-core`

### Deploy all kubernetes dockerized applications to an environment (aws)

---

**Notes on Fresh Installation**

Before running the script to redeploy all ingest components, make sure that secrets have been properly defined in the AWS security manager. At the time of writing, the following secrets are required to be defined in `dcp/ingest/<deployment_env>/secrets` to ensure that deployments go smoothly:

* `emails`
* `staging_api_key` (retrieve this from `dcp/upload/staging/secrets`)
* `exporter_auth_info`

---

1. Make sure you have followed the instructions above to create or access an existing eks cluster
2. Change the branch or tag in `config/environment_ENVNAME` if needed where ENVNAME is the environment you are deploying to.
3. `cd apps`
4. `make deploy-all-apps` where APPNAME is the name of the ingest application.

### After Deployment

All requests to the Ingest cluster go through the Ingress controller. Any outward facing service needs to be mapped to the Ingress service for it to work correctly. This is set through the AWS Route 53 mapping.

1. The first step is to retrieve the external IP of the Ingress service load balancer. This can be done using `kubectl get services -l app=nginx-ingress`.
2. Copy the external IP and go the Route 53 service dashboard on the AWS Web console.
3. From the Hosted Zones, search for `<deployment_env>.data.humancellatlas.org` and search for Ingest related records.
4. Update each record to use the Ingress load balancer external IP as alias.
5. To ensure that each record are set correctly, run a quick test using the Test Record Set facility on the AWS Web console.

## Deploy cloudwatch log exporter
1. Make sure you have followed the instructions above to create or access an existing eks cluster
2. Source the configuration file for the environment
3. Make sure the secrets api-keys and aws-keys are deployed substituted with valid base64 encoded values
4. `cd infra` and `make install-infra-helm-chart-fluentd-cloudwatch`

## CI/CD Setup

### Promote one application environment configurations to another (ie dev => integration)
Coming soon

## Local Setup

### Local deployment with Minikube
Coming soon

## Accessing RabbitMQ Management UI
tldr: Use this command: `kubectl port-forward rabbit-0 15672:15672`

`kubectl port-forward <localhost-port>:15672`
https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

1. Get the rabbit service local port
`kubectl get service rabbit-service`
2. Get the rabbit service pod
`kubectl get pods | grep rabbit`
3. Access the RabbitMQ Management UI
`kubectl port-forward rabbit-0 15672:15672`
