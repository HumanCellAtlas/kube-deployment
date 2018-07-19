deployment_stage = ${DEPLOYMENT_STAGE}
kubeconfig_path=${KUBECONFIG_PATH}

create-cluster-%:
	# Add User confirmation of action and environment here and then apply -auto-confirm flag on terraform
	# This step is idempotent and can be run again if the cluster needs to be modified.
	$(MAKE) init-$(*)
	. ../config/environment_$(*) && terraform apply
	$(MAKE) retrieve-kubeconfig-$(*)
	$(MAKE) apply-dashboard-configs-$(*)
	$(MAKE) apply-env-configs-$(*)
	. ../config/environment_$(*) && helm init --service-account tiller --wait
	$(MAKE) deploy-backend-services-$(*)

deploy-backend-services-%:
	# Add User confirmation of action and environment here and then apply -auto-confirm flag on terraform
	$(MAKE) set-context-$(*)
	$(MAKE) install-infra-helm-chart-mongo
	$(MAKE) install-infra-helm-chart-rabbit
	$(MAKE) install-infra-helm-chart-redis
	$(MAKE) install-infra-helm-chart-fluentd-cloudwatch

modify-cluster-%:
	# Add User confirmation of environment and action here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	. ../config/environment_$(*) && terraform apply

destroy-cluster-%:
	# Add User confirmation of action here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	$(MAKE) set-context-$(*)
	. ../config/environment_$(*) && helm ls --all --short | xargs -L1 helm delete --purge
	. ../config/environment_$(*) && terraform destroy

retrieve-kubeconfig-%:
	# confirm environment here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	mkdir -p ../config/cluster-secrets/
	mkdir -p $(*)
	terraform output kubeconfig > ../config/cluster-secrets/kubeconfig_$(*)
	KUBECONFIG=~/.kube/config:$(kubeconfig_path) kubectl config view --flatten > mergedkub && mv mergedkub ~/.kube/config
	terraform output namespace > $(*)/namespace.yaml
	. ../config/environment_$(*) && kubectl apply -f $(*)/namespace.yaml
	rm -rf $(*)
	$(MAKE) set-context-$(*)
	helm init --service-account tiller

setup-dashboard-%:
	kubectx ingest-eks-$(*)
	kubens $(*)-environment
	kubectl proxy

apply-env-configs-%:
	# confirm environment here
	$(MAKE) init-$(*)
	$(MAKE) set-context-$(*)
	rm -rf $(*)
	mkdir -p $(*)
	terraform output config_map > $(*)/config_map.yaml
	terraform output tilleraccount > $(*)/tiller_account.yaml
	terraform output storageclass > $(*)/storageclass.yaml
	. ../config/environment_$(*) && kubectl apply -f $(*)/config_map.yaml
	. ../config/environment_$(*) && kubectl apply -f $(*)/tiller_account.yaml
	. ../config/environment_$(*) && kubectl apply -f $(*)/storageclass.yaml
	. ../config/environment_$(*) && kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
	rm -rf $(*)

install-infra-helm-chart-%:
	cd helm-charts && helm package $(*)
	. ../config/environment_$(deployment_stage) && cd helm-charts && helm upgrade $(*) $(*) --set namespace=$(deployment_stage)-environment --force --install
	cd helm-charts && rm *.tgz

apply-dashboard-configs-%:
	# confirm environment here
	$(MAKE) set-context-$(*)
	. ../config/environment_$(*) && kubectl apply -f dashboard-configs/

init-%:
	# confirm environment here
	rm -rf .terraform
	. ../config/environment_$(*) && . scripts/init.sh

set-context-%:
	kubectx ingest-eks-$(*)
	kubens $(*)-environment
