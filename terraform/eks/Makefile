
create-cluster-%:
	# Are you sure you want to create should be added here
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && $(MAKE) terraform-apply
	$(MAKE) retrieve-kubeconfig-$(*)
	$(MAKE) apply-dashboard-configs
	$(MAKE) create-env-configs-$(*)
	$(MAKE) apply-env-configs-$(*)

modify-cluster-%:
	# Are you sure you want to modify should be added here
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && $(MAKE) terraform-apply
	$(MAKE) retrieve-kubeconfig-$(*)

retrieve-kubeconfig-%:
	$(MAKE) init-$(*)
	terraform output kubeconfig > ../../config/cluster_secrets/kubeconfig_$(*)

create-env-configs-%:
	$(MAKE) init-$(*)
	rm ../../kubernetes/$(*)/*
	terraform output namespace > ../../kubernetes/$(*)/namespace.yaml
	terraform output config_map > ../../kubernetes/$(*)/config_map.yaml

apply-env-configs-%:
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/$(*)/

apply-dashboard-configs:
	. ../../config/environment_$(*) && kubectl apply -f ../../kubernetes/dashboard/

cluster-plan-%:
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && $(MAKE) terraform-plan

destroy-cluster-%:
	# Are you sure you want to delete should be added here
	$(MAKE) init-$(*)
	. ../../config/environment_$(*) && $(MAKE) terraform-destroy

init-%:
	rm -rf .terraform
	. ../../config/environment_$(*) && . ../../scripts/init.sh

terraform-%:
	terraform $(*) \
		$(shell [[ $(*) == "apply" ]] && echo "-auto-approve" || true)
