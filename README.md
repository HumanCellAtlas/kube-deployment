# Ingest Service Deployment

Deployment setup for the Ingestion Service on  [Kubernetes](https://kubernetes.io/) clusters.

## Set up local environment
### Mac
1. git clone https://github.com/HumanCellAtlas/ingest-kube-deployment.git
2. Install terraform: `brew install terraform` or Instructions found at https://www.terraform.io/intro/getting-started/install.html.
3. Install awscli: `pip install awscli`.
4. Install heptio-authenticator-aws: Follow 'To install heptio-authenticator-aws for Amazon EKS' at https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html.
5. Install kubectl: `brew install kubernetes-cli`
6. Install kubectx (kubens included): `brew install kubectx`
7. Install helm: `brew install kubernetes-helm` or instructions found at https://github.com/kubernetes/helm.

### Ubuntu
1. git clone https://github.com/HumanCellAtlas/ingest-kube-deployment.git
1. Install terraform with the [terraform instructions](https://learn.hashicorp.com/terraform/getting-started/install.html). If you install with `sudo snap install terraform` you may run into the error `Error configuring the backend "s3": NoCredentialProviders: no valid providers in chain. Deprecated.`
1. Install awscli: `pip install awscli`.
1. Install heptio-authenticator-aws: Follow 'To install heptio-authenticator-aws for Amazon EKS' at https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html.
1. Install kubectl: `sudo snap install kubectl --classic`
1. Install kubectx and kubens following instructions at https://github.com/ahmetb/kubectx
1. Install helm: `sudo snap install helm --classic`

# Access/Create/Modify/Destroy EKS Clusters

## Access existing ingest eks cluster (aws)
These steps assumes you have the correct aws credentials and local environment tools set up correctly. This only has to be run one time.
1. `source config/environment_ENVNAME` where ENVNAME is the name of the environment you are trying to access
2. `cd infra`
3. `make retrieve-kubeconfig-ENVNAME` where ENVNAME is the name of the environment you are trying to access
4. `kubectl`, `kubens`, `kubectx`, and `helm` will now be tied to the cluster you have sourced in the step above.

## How to access dashboard
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
1. `kubectx ingest-eks-ENVNAME` where ENVNAME is the name of the cluster environment you are trying to access
2. Generate token:
	`kubectl -n kube-system describe secrets/$(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`
3. Start the proxy:
	`kubectl proxy`
4. Browse to the dashboard endpoint at http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
5. Choose Token and paste token from step 2 above

## Create new ingest eks cluster (aws)
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

## Modify and deploy updated EKS and AWS infrastructure
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
1. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment you are trying to modify.
2. Update infra/eks.tf as desired.
2. `cd infra`
3. `make modify-cluster-ENVNAME` where ENVNAME reflects the name of the environment you are trying to modify.

## Destroy ingest eks cluster (aws)
These steps assumes you have the correct aws credentials + local environment tools set up correctly and that you have followed the instructions to access the existing cluster.
These steps will bring down the entire infrastructure and all the resources for your ingest kubernetes cluster and environment. This goes all the way up to the VPC that was created for this environment's cluster.
1. Follow setups 2-5 in 'Create new ingest eks cluster (aws)' if config/environment_ENVNAME does not exist where ENVNAME is the environment you are trying to destroy
2. `source config/environment_ENVNAME` where ENVNAME reflects the name of the environment in the config file you created above
3. `cd infra`
4. `make destroy-cluster-ENVNAME` where ENVNAME is the name of the environment you are trying to destroy

# Install and Upgrade Core Ingest Backend Services (mongo, redis, rabbit)

## Install backend services (mongo, redis, rabbit)
1. `cd infra`
2. `make deploy-backend-services-ENVNAME` where ENVNAME is the name of the environment you are trying to create.

## Upgrade backend services (mongo, redis, rabbit)
Coming soon

# Deploy and Upgrade Ingest Applications

## Deploy one kubernetes dockerized applications to an environment (aws)
1. Make sure you have followed the instructions above to create or access an existing eks cluster
2. Change the branch or tag in `config/environment_ENVNAME` if needed where ENVNAME is the environment you are deploying to.
3. `cd apps`
4. `make deploy-app-APPNAME` where APPNAME is the name of the ingest application. For example, `make deploy-app-ingest-core`

## Deploy all kubernetes dockerized applications to an environment (aws)
1. Make sure you have followed the instructions above to create or access an existing eks cluster
2. Change the branch or tag in `config/environment_ENVNAME` if needed where ENVNAME is the environment you are deploying to.
3. `cd apps`
4. `make deploy-all-apps` where APPNAME is the name of the ingest application.

# CI/CD Setup

## Promote one application environment configurations to another (ie dev => integration)
Coming soon

# Local Setup

## Local deployment with Minikube
Coming soon

# Accessing RabbitMQ Management UI

`kubectl port-forward <localhost-port>:15672`
https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

1. Get the rabbit service local port
`kubectl get service rabbit-service`
2. Get the rabbit service pod
`kubectl get pods | grep rabbit`
3. Access the RabbitMQ Management UI
`kubectl port-forward rabbit-0 15672:15672`

