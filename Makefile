ENV?=.env.dev
-include $(ENV)

DOCKER=docker
COMPOSE_ARGS=
DOCKER-COMPOSE=docker-compose
DOCKER-LOGS-TAIL=50
THIS_FILE:=$(lastword $(MAKEFILE_LIST))
USR_ID=$(shell id -u)
USR_GR=$(shell id -g)


##
##DEFAULT #####################################################################
##

.PHONY: all
all:			## Default. Display this help.
all: help

##
##RUN #########################################################################
##

.PHONY: install
install:		## Start the services on your machine, stopping any running instances first.
install: stop up 

.PHONY: reinstall
reinstall:		## Restart as clean slate all the services on your machine.
reinstall: cleanup build up 

.PHONY: up
up: 			## Just straight docker-compose up -f.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) up -d #--no-deps

.PHONY: stop
stop:			## Stop the running services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) stop

.PHONY: down
down: 			## Stop and remove the running services.
down: stop
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) rm -vf

.PHONY: ps
ps:			## Show all the running services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) ps

.PHONY: logs
logs:			## Output logs of the running services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) logs -f --tail=$(DOCKER-LOGS-TAIL)

.PHONY: logs-nice
logs-nice:		## Output logs of the running services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) logs -f --tail=$(DOCKER-LOGS-TAIL) | grep 'nginx_\|fpm' | grep -v 'agent-status\|status\|statuses'

.PHONY: logs-all
logs-all:		## Output all the logs of the running services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) logs -f

.PHONY: logs-php
logs-php:		## Output all the logs of the running php-fpm services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) logs -f --tail=$(DOCKER-LOGS-TAIL) | grep "fpm"

.PHONY: logs-nginx
logs-nginx:		## Output all the logs of the running nginx services.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) logs -f --tail=$(DOCKER-LOGS-TAIL) | grep "nginx_"

.PHONY: restart
restart:		## Restart the running services.
restart:
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) restart

##
##NEXTCLOUD #######################################################################
##

.PHONY: occ
occ:			## Run NextCloud OCC cli management tool. Usage: make occ cmd=<occ command>
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec -u www-data nextcloud php occ $(cmd)

.PHONY: maintenance-on
maintenance-on:		## Maintenance mode ON
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec -u www-data nextcloud php occ maintenance:mode --on

.PHONY: maintenance-off
maintenance-off:	## Maintenance mode OFF
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec -u www-data nextcloud php occ maintenance:mode --off

.PHONY: db-dump
db-dump:		## Create database dump. Using `bash -c '...'` otherwise the output would try to go the host.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec dbmaster bash -c 'mysqldump --single-transaction -h 127.0.0.1 -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) > /var/lib/mysql/BACKUP.nextcloud.database.sql'

.PHONY: post-setup
post-setup:		## Post Nextcloud database optimisation: missing indexes and conversion to big int for some columns
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec -u www-data nextcloud php occ db:add-missing-indices
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec -u www-data nextcloud php occ db:convert-filecache-bigint

##
##UTILS #######################################################################
##

.PHONY: config
config:			## Check docker-compose resolved configuration
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) config

.PHONY: cli
cli:			## bash in a running Docker machine: make cli id=<docker_image_name>
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) exec $(id) bash

.PHONY: stats
stats:			## Get resource usage stats of all running services
	$(DOCKER) stats $($(DOCKER) ps --format={{.Names}})

.PHONY: restart-service
restart-service:	## Restart a running Docker machine: make restart-service id=<docker_image_name>
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) stop $(id)
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) kill $(id)
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) rm -f $(id)
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) up -d $(id)

.PHONY: stop-service
stop-service:		## Stop a running Docker machine: make stop-service id=<docker_image_name>
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) stop $(id)

##
##BUILD ########################################################################
##

.PHONY: build
build:			## Build all the Docker images defined in the docker-compose files.
	$(DOCKER-COMPOSE) $(COMPOSE_ARGS) build

##
##SYS UTILS ###################################################################
##

.PHONY: cleanup
cleanup:		## Remove all the data files and Docker images.
cleanup: down
	$(DOCKER) network prune -f
	$(DOCKER) volume prune

.PHONY: wipe
wipe: cleanup		## Warning! This will remove the data files and ALL the Docker images from your machine, even the ones not related to the project!
	$(DOCKER) rm -f $$($(DOCKER) ps -a -q) >/dev/null 
	$(DOCKER) rmi -f $$($(DOCKER) images -q) >/dev/null 

help:			## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo ""
	@echo "\\033[0;32mEnvironment file: $(ENV)\\033[0;39m"
	@echo ""
