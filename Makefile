.PHONY: build run exec trash
build:
	@docker build --no-cache \
		-t ghcr.io/$(owner)/dev-env-ubuntu-base-img:$(version) .
run:
	docker run -it --rm --name dev-env-ubuntu-base-cont -d ghcr.io/$(owner)/dev-env-ubuntu-base-img:$(version)

exec:
	docker exec -it dev-env-ubuntu-base-cont /usr/bin/zsh

trash:
	docker container stop dev-env-ubuntu-base-cont
