export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh

.PHONY: install build run exec trash

install:
	
	@$(INSTALL_HOST_DEPENDENCIES)

build:
	@docker build --no-cache \
		-t ghcr.io/$(OWNER)/dev-env-ubuntu-base-img:$(DOCKER_TAG_VERSION_NUMBER) . --progress plain

# Requires authentication to Github Container Registry, to authenticate reference README
push:
	@docker push ghcr.io/$(OWNER)/dev-env-ubuntu-base-img:$(DOCKER_TAG_VERSION_NUMBER)

run:
	docker run -it --rm --name dev-env-ubuntu-base-cont -d ghcr.io/$(OWNER)/dev-env-ubuntu-base-img:$(DOCKER_TAG_VERSION_NUMBER)

exec:
	docker exec -it dev-env-ubuntu-base-cont /usr/bin/zsh

trash:
	docker container stop dev-env-ubuntu-base-cont
