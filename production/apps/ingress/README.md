# Ingest Ingress

Ingest reverse proxy mechanism is handled through Kubernetes ingress rules backed by the NGINX ingress controller. Components involved in this system are setup through Helm package manager.

## Setting Up ingress in Deployment

Helm release for the Ingest ingress require environment-specific value files along with the default `value.yaml`. This is due to the fact that services, and their respective ingress rules might change based on the requirements for a specific deployment stage.

When all configuration for the environment is done, setup for the ingress facility for a deployment environment can be invoked through:

    make setup-ingress

in the `apps` directory. This assumes that all local environment variables are all set correctly.

### Configuration

Ingress rules for specific environment can be configured through the respective deployment environment value file. For example, the ingress rules for dev environment are defined in `dev.yaml`. To add a new set of configuration for another environment, a new value file can be created. For general configuration that applies to all environments, the settings can be modified or added in `values.yaml`.

Environment-specific value file follows a DSL-like configuration pattern specified in `templates/ingress.yaml`. At the minimum, an ingress rule entry under `hosts` configuration requires an Ingest service name and the domain it's mapped to.

### SSL Certificate

SSL certificates for Ingest deployments are managed through AWS. The certificates can be referred to using their assigned ARN that are set to the `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` annotation.

#### Enforce HTTPS through Redirect

Through Kubernetes configuration, HTTPS can be strictly implemented by redirecting non-HTTPS request. This can be enabled through the `nginx.ingress.kubernetes.io/force-ssl-redirect` annotation in `templates/ingress.yaml`.

### Route53 Mapping

Once all of the related ingress components have been deployed through Helm release, especially when a new service is mapped through ingress rules, domain names managed through AWS need to be mapped to dispatch request to the NGINX ingress controller. The first step in achieving this is to take note of the hostname assigned by AWS to the ingress controller load balancer. One way to retrieve this is by traversing the JSON returned by `kubectl`:

    kubectl get services -o jsonpath="{$.items[?(@.metadata.name=='ingress-nginx-ingress-controller')].status.loadBalancer.ingress[0].hostname}"

The result of this command can be piped to the clipboard using utilities like `pbcopy` for macOS.

The ingress controller hostname can then be assigned to all domain names in the proper hosted zone through the AWS console:

1. Using the AWS console, open the Route53 interface.
1. Locate the hosted zone for the deployment environment, for example, `dev.data.humancellatlas.org`.
1. Within the hosted zone, locate the domain name original mapped to the service, for example, `api.ingest.dev.data.humancellatlas.org`.
1. Usually, this domain name would be set up as an alias type mapped to a specific load balancer for a specific Ingest service. Replace the alias target with the domain name for the ingress controller that was previously noted. Alternatively, to create a new service intended to pass through the ingress controller, a new record set with type alias should be created.
1. Save the record set, and optionally test it through the `Test Record Set` option on AWS console.

## Helm

Components to implement ingress are packaged through Helm. While a convenience method is provided through the Makefile, there is always the option to release directly through the `helm` utilities.

### Install

To do a fresh install:

    helm install -f ingress/values.yaml -f ingess/<env_config>.yaml -n ingress ingress

### Upgrade

To upgrade an existent release:

	helm upgrade -f ingress/values.yaml -f ingess/<env_config>.yaml ingress ingress

In case an error like the following occurs:

    Error: found in requirements.yaml, but missing in charts/ directory: <nginx-ingress_dir>

a quick fix could be:

    helm dependency update ingress
