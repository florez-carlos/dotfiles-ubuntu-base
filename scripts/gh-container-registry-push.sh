#!/bin/bash

printf "%s\n" ""
printf "%s\n" " -> Checking if there's existing latest version"
printf "%s\n" ""
sleep 1
latest_id=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GIT_PAT}"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/users/${GIT_USER_USERNAME}/packages/container/dev-env-ubuntu-base-img/versions | jq -r '.[] | select(any(.metadata.container; ."tags" | index("latest"))) | .id')

if [ -n "${latest_id}" ];
then

    printf "%s\n" ""
    printf "%s\n" " -> Latest exists! Deleting current latest id#: ${latest_id}"
    printf "%s\n" ""
    sleep 1

    curl -L \
  -X DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GIT_PAT}"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/users/${GIT_USER_USERNAME}/packages/container/dev-env-ubuntu-base-img/versions/${latest_id}
else
    printf "%s\n" ""
    printf "%s\n" " -> No existing latest found"
    printf "%s\n" ""
    sleep 1
fi


printf "%s\n" ""
printf "%s\n" " -> Pushing new version: ${IMAGE_VERSION}"
printf "%s\n" ""
sleep 1
docker push ghcr.io/$(GIT_USER_USERNAME)/dev-env-ubuntu-base-img:v${IMAGE_VERSION}

printf "%s\n" ""
printf "%s\n" " -> Pushing new version named as latest"
printf "%s\n" ""
sleep 1
docker push ghcr.io/$(GIT_USER_USERNAME)/dev-env-ubuntu-base-img:latest

