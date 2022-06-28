export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
export TMP_CONFIG := $(MODULE_HOME)/config
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh


install:
	@$(INSTALL_HOST_DEPENDENCIES)

build:
	@docker build --no-cache -t dev-env-ubuntu-base-img .

run:
	docker run -it --rm --name dev-env-ubuntu-base-cont -d dev-env-ubuntu-base-img

exec:
	docker exec -it dev-env-ubuntu-base-cont /usr/bin/zsh

trash:
	docker container stop dev-env-ubuntu-base-cont
