
create-cluster-%:
	# Add User confirmation of action here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && terraform apply
	$(MAKE) retrieve-kubeconfig-$(*)
	$(MAKE) apply-dashboard-configs-$(*)
	$(MAKE) create-env-configs-$(*)
	$(MAKE) apply-env-configs-$(*)
	. ../../config/environment_$(*) && helm init --service-account tiller --tiller-namespace $(*)-environment

modify-cluster-%:
	# Add User confirmation of action here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && terraform apply
	$(MAKE) retrieve-kubeconfig-$(*)

destroy-cluster-%:
	# Add User confirmation of action here and then apply -auto-confirm flag on terraform
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && terraform destroy

retrieve-kubeconfig-%:
	$(MAKE) init-$(*)
	mkdir -p ../../kubernetes/cluster-secrets/
	terraform output kubeconfig > ../../kubernetes/cluster-secrets/kubeconfig_$(*)
	# add this to the path so don't have to do this again and can share multiple clusters

create-env-configs-%:
	$(MAKE) init-$(*)
	rm -rf ../../kubernetes/$(*)
	mkdir -p ../../kubernetes/$(*)
	# move the following out of terraform into helm charts
	terraform output namespace > ../../kubernetes/$(*)/namespace.yaml
	terraform output config_map > ../../kubernetes/$(*)/config_map.yaml
	terraform output tilleraccount > ../../kubernetes/$(*)/tiller_account.yaml

apply-env-configs-%:
	# move the following out of terraform into helm charts
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/$(*)/namespace.yaml
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/$(*)/config_map.yaml
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/$(*)/tiller_account.yaml

apply-dashboard-configs-%:
	# move the following out of terraform into helm charts
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/dashboard-configs/

deploy-helm-charts-%:
	$(MAKE) package-helm-chart-mongo
	. ../../config/environment_$(*) && $(MAKE) install-helm-chart-mongo

install-helm-chart-%:
	cd ../../kubernetes/helm-charts && . ../../config/environment_$(TF_VAR_deployment_stage) && helm install $(*) --tiller-namespace $(TF_VAR_deployment_stage)-environment

package-helm-chart-%:
	cd ../../kubernetes/helm-charts && helm package $(*)

init-%:
	rm -rf .terraform
	. ../../config/environment_$(*) && . ../../terraform/scripts/init.sh
