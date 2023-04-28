#!/bin/bash

printf "%s\n" ""
printf "%s\n" " -> Pushing new version: ${IMAGE_VERSION}"
printf "%s\n" ""
sleep 1
docker push ghcr.io/${GIT_USER_USERNAME}/dev-env-ubuntu-base-img:v${IMAGE_VERSION}
