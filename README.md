## Setup

This project assumes you have Kubernetes already running and `kubectl` properly set for one of the following environments:
- Minkube
- Kubernetes for Mac
- AWS 

## Usage

```
$ make help

 General:
     deploy-mac                    Deploy NextCloud in K8s for Mac
     deploy-aws                    Deploy NextCloud in AWS environment
     deploy-minikube               Deploy NextCloud in Minikube environment
     deploy                        Deploy NextCloud: bootstrap and catalogue (default to Minikube)
     -                             Use K8S_ENV=mac|aws|minikube to override the default environment
     full-deploy                   Deploy NextCloud: bootstrap, catalogue, catalogue-extra
     bootstrap                     Deploy NextCloud base environment (config, ingress, storage, etc.)
     catalogue                     Deploy NextCloud config service and admin
     catalogue-extra               Deploy NextCloud extra components (jaeger, turbine, gatekeeper, etc.)
     open-nextcloud                Open NextCloud admin interface
     delete-nextcloud              Remove all NextCloud services from K8s
     help                          Show this help
     dashboard                     Install the K8s dasboard
     dashboard-open                Open the K8s dasboard
```

Please make sure to set an appropriate `GIT_PASSWORD` value in `bootstrap/config.yaml` in order to download the config repository from GitLab.