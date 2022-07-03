# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
dev environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the base dependencies then proceed with this repo: 
[Dotfiles](https://gtihub.com/florez-carlos/dotfiles) 

## Installation

### Install required dependencies on host machine

This is required to pull the repo and invoke the Makefile targets

```bash
apt-get update -y
apt-get upgrade -y
apt-get install git make curl gpg -y
```

### Define OWNER and VERSION environment variables

These will be used to tag the Docker image

```bash
export OWNER=${GITHUB_OWNER}
export DOCKER_TAG_VERSION_NUMBER=${DOCKER_TAG_VERSION}
```

### Define the Personal Authentication Token environment variable and login to the Github container registry

This is required to push the image to the Github Container Registry

```bash
export GIT_PAT={GITHUB_PERSONAL_AUTHENTICATION_TOKEN}
echo $GIT_PAT | docker login ghcr.io -u $OWNER --password-stdin
```

### Install docker

If using WSL2, skip the ubuntu section and continue with the [WSL2 - ubuntu distro instructions](#wsl2---ubuntu-distro)

#### Ubuntu

This will install Docker and add the user to the docker group

```bash
make install
```

Before proceeding, log out and log back in for the group change to take effect.

#### WSL2 - ubuntu distro

Follow these instructions to install [Docker Desktop](https://docs.docker.com/desktop/windows/install/)


### Build the image

Invoke the build target

This build will take a while, be patient :)

```bash
make build
```

### Push the image to the registry


```bash
docker push ghcr.io/{OWNER}/dev-env-ubuntu-base-img:{DOCKER_TAG_VERSION_NUMBER}
```

### Optional: running the image

If you need to run and exec the image for any reason then invoke the following

```bash
make run
make exec
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
