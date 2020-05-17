# Variables
# ---------------------------------------------------------------------------

K8S_ENV:=minikube
THIS_FILE:=$(lastword $(MAKEFILE_LIST))


# Recipes
# ---------------------------------------------------------------------------

.PHONY: all
all: help

.PHONY: deploy-mac ## Deploy nextcloud in K8s for Mac
deploy-mac:
	@$(MAKE) -f $(THIS_FILE) deploy K8S_ENV=mac

.PHONY: deploy-aws ## Deploy nextcloud in AWS environment 
deploy-aws:
	@$(MAKE) -f $(THIS_FILE) deploy K8S_ENV=aws

.PHONY: deploy-minikube ## Deploy nextcloud in Minikube environment
deploy-minikube:
	$(call minikubeEnableIngress)
	@$(MAKE) -f $(THIS_FILE) deploy K8S_ENV=minikube

.PHONY: deploy ## Deploy nextcloud: bootstrap and catalogue (default to Minikube)
.PHONY: - ## Use K8S_ENV=mac|aws|minikube to override the default environment
deploy: bootstrap catalogue

.PHONY: full-deploy ## Deploy nextcloud: bootstrap, catalogue, catalogue-extra
full-deploy: bootstrap catalogue catalogue-extra

.PHONY: bootstrap ## Deploy nextcloud base environment (config, ingress, storage, etc.)
bootstrap:
	$(call checkValidK8sEnvironment)
	$(call kubectl, apply -f bootstrap/config.yaml)
	$(call kubectl, apply -f bootstrap/ingress.yaml)
	$(call kubectl, apply -f bootstrap/storage-$(K8S_ENV).yaml)
	$(call kubectl, apply -f bootstrap/pvclaim-logs.yaml)

.PHONY: catalogue ## Deploy nextcloud config service and admin
catalogue:
	$(call kubectl, apply -f catalogue/configservice)
	$(call kubectl, apply -f catalogue/admin)

.PHONY: open-nextcloud ## Open nextcloud admin interface
open-nextcloud:
	@open http://kubernetes-url:8001/api/v1/namespaces/default/services/http:admin:9988/proxy

.PHONY: delete-nextcloud ## Remove all nextcloud services from K8s
delete-nextcloud:
	kubectl delete deployment,service,pod,ingress,configmap,persistentvolumeclaim,storageclass -l stack=nextcloud

.PHONY: help ## Show this help
help:
	@echo ""
	@perl -e '$(help)' $(MAKEFILE_LIST)


# K8s stuff/helpers
# ---------------------------------------------------------------------------

.PHONY: dashboard ### Install the K8s dasboard
dashboard: heapster dashboard-kill dashboard-install dashboard-start dashboard-ingress dashboard-open

.PHONY: dashboard-install
dashboard-install:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

.PHONY: dashboard-start
dashboard-start:
	screen -S k8s-dashboard -dm kubectl proxy

.PHONY: dashboard-ingress
dashboard-ingress:
	$(call kubectl,apply,-f system/dashboard-ingress.yaml)

.PHONY: dashboard-kill
dashboard-kill:
	screen -S k8s-dashboard -X quit & ps aux | grep -v grep | grep " kubectl proxy" | awk '{print $$2}' | xargs kill

.PHONY: dashboard-open ## Open the K8s dasboard
dashboard-open:
	@open http://kubernetes-url:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

.PHONY: heapster
heapster:
	rm -Rf git /tmp/heapster && git clone https://github.com/kubernetes/heapster.git /tmp/heapster && /tmp/heapster/deploy/kube.sh start


# Functions
# ---------------------------------------------------------------------------

define kubectl
	kubectl $1 $2 $3
endef

define checkValidK8sEnvironment
	@if [ "$(K8S_ENV)" != "minikube" ] && [ "$(K8S_ENV)" != "mac" ] && [ "$(K8S_ENV)" != "aws" ]; then \
		echo "\\033[1;31mPlease set K8S_ENV to one of the following values: mac|aws|minikube\\033[0;39m"; \
		exit 1; \
	fi
endef

define minikubeEnableIngress
	minikube addons enable ingress
endef

define help
%help; while(<>){push@{$$help{$$2//'General'}},[$$1,$$3] \
if/^\.PHONY:\s?([\w-_%]+)\s*.*\#\#\s?(?:@(\w+))?\s(.*)$$/}; \
print" $$_:\n", map"     $$_->[0]".(" "x(30-length($$_->[0])))."$$_->[1]\n",\
@{$$help{$$_}},"\n" for keys %help;
endef