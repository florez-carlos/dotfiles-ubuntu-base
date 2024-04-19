export MODULE_HOME := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(MODULE_HOME)/scripts
INSTALL_HOST_DEPENDENCIES := $(SCRIPTS_DIR)/install-host-dependencies.sh
GH_CONTAINER_REGISTRY_PUSH := $(SCRIPTS_DIR)/gh-container-registry-push.sh
GH_CONTAINER_REGISTRY_PUSH_LATEST := $(SCRIPTS_DIR)/gh-container-registry-push-latest.sh
export IMAGE_VERSION := 2.1.0

.PHONY: install build push run exec trash

install:
	
	@$(INSTALL_HOST_DEPENDENCIES)

build:
	@DOCKER_BUILDKIT=1 docker build --no-cache --network=host --progress plain \
	-t ghcr.io/$(GIT_USER_USERNAME)/dev-env-ubuntu-base-img:v$$IMAGE_VERSION .

build-latest:
	@docker build --no-cache \
		-t ghcr.io/$(GIT_USER_USERNAME)/dev-env-ubuntu-base-img:latest . --progress plain

# Requires authentication to Github Container Registry, to authenticate reference README
push:
	@$(GH_CONTAINER_REGISTRY_PUSH)

# Requires authentication to Github Container Registry, to authenticate reference README
push-latest:
	@$(GH_CONTAINER_REGISTRY_PUSH_LATEST)

run:
	docker run -it --rm --name dev-env-ubuntu-base-cont -d ghcr.io/$(GIT_USER_USERNAME)/dev-env-ubuntu-base-img:v$$IMAGE_VERSION

exec:
	docker exec -it dev-env-ubuntu-base-cont /usr/bin/zsh

trash:
	docker container stop dev-env-ubuntu-base-cont

