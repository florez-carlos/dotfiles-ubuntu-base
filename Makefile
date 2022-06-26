export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export TMP_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh


install:
	@$(INSTALL_HOST_DEPENDENCIES)

build:
	@docker -t dev-env-ubuntu-base-img .

run:
	docker run -it --rm --name dev-env-cont -d -v $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) dev-env-img

exec:
	docker exec -it dev-env-cont /usr/bin/zsh

trash:
	docker container stop dev-env-cont
