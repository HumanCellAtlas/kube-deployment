# Ingest Service Deployment

Deployment setup for the Ingestion Service on  [Kubernetes](https://kubernetes.io/) clusters.

## Set up local environment to access existing clusters
1. git clone https://github.com/HumanCellAtlas/ingest-kube-deployment.git
2. Install terraform: `brew install terraform` or Instructions found at https://www.terraform.io/intro/getting-started/install.html.
3. Install awscli: `pip install awscli`.
4. Install heptio-authenticator-aws: Follow 'To install heptio-authenticator-aws for Amazon EKS' at https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html.
5. Install helm: `brew install kubernetes-helm` or instructions found at https://github.com/kubernetes/helm.

# Access/Create/Modify/Destroy EKS Clusters

## Access existing ingest eks cluster (aws)
This step assumes you have the correct aws credentials and local environment tools set up correctly
1. `source config/environment_ENVNAME` where ENVNAME is the name of the environment you are trying to access
2. `kubectl`, `kubens`, `kubectx`, and `helm` will now be tied to the cluster you have sourced in the step above.

## How to access dashboard
1. Run `source config/environment_ENVNAME` where ENVNAME is the name of the environment's dashboard you are trying to access
2. Generate a token using the command:
	`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`
3. Start the kubectl proxy:
	`kubectl proxy`
4. Open the following link with a web browser to access the dashboard endpoint: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
5. Choose Token, paste the token output from the previous command into the Token field, and choose SIGN IN.

## Create new ingest eks cluster (aws)
These steps will set up a new ingest environment from scratch via terraform and will also apply all kubernetes monitoring and dashboard configs, RBAC role and aws auth setup.
1. Make sure you have set up your local environment and have the appropriate tools from above
2. `cp config/environment_template config/environment_ENVNAME` where envname should reflect the name of the environment you are trying to create.
3. Replace all values marked as 'PROVIDE...' with the appropriate value
4. Ensure the aws profile name in this config is mapped to the name of the aws profile in your ~/.aws/ path that has admin access to the relevant aws account.
5. Ensure the VPC IP in this config file is a valid and unique VPC IP value.
6. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment in the config file you created above
6. `cd infra`
7. `make create-cluster-ENVNAME` where ENVNAME is the name of the environment you are trying to create
8. Follow the steps to access the kubernetes dashboard. Once you see one active tiller pod in the environment namespace, continue to the next step.
9. `make deploy-backend-services-ENVNAME` where ENVNAME is the name of the environment you are trying to create.

## Modify and deploy updated EKS and AWS infrastructure
Coming soon

## Destroy ingest eks cluster (aws)
These steps will bring down the entire infrastructure and all the resources for your ingest kubernetes cluster and environment. This goes all the way up to the VPC that was created for this environment's cluster.
1. Make sure you have set up your local environment and have the appropriate tools from above
2. Follow setups 2-5 in 'Create new ingest eks cluster (aws)' if config/environment_ENVNAME does not exist where ENVNAME is the environment you are trying to destroy
3. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment in the config file you created above
4. `cd terraform/eks`
5. `make destroy-cluster-ENVNAME` where ENVNAME is the name of the environment you are trying to destroy

# Install and Upgrade Core Ingest Backend Services (mongo, redis, rabbit)

## Install backend services (mongo, redis, rabbit)
Coming Soon

## Upgrade backend services (mongo, redis, rabbit)
Coming soon

# Deploy and Upgrade Core Ingest Applications

Core Applications:

## Deploy one or all kubernetes dockerized applications (aws)
Coming soon

## Deploy ingest auth lambda application (aws)
Coming soon

# CI/CD Setup

## Promote one application environment configurations to another (ie dev => integration)
Coming soon

# Local Setup

## Local deployment with Minikube
Coming soon
