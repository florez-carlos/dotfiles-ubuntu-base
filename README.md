# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
development environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the base dependencies then proceed with this repo: 
[Dotfiles](https://gtihub.com/florez-carlos/dotfiles) 

The following installation instructions support:

- Ubuntu
- WSL2 - Ubuntu distro

NOTE: Active development of this repo requires use of the ["Dotfiles"](https://github.com/florez-carlos/dotfiles)
containerized development environment.

## Table of Contents

* [Install Git Hooks](#install-git-hooks)
* [Export Required Env Variables](#export-required-env-variables)
* [Install Required Dependencies on Host Machine](#install-required-dependencies-on-host-machine)
* [Install Docker](#install-docker)
  * [Ubuntu](#ubuntu)
  * [WSL2 - Ubuntu distro](#wsl2---ubuntu-distro)
* [Optional: Manually building the image and pushing to Github Container Registry] (#optional:-manually-building-the-image-and-
pushing-to-github-container-registry)
  * [Login to the Github Container Registry](login-to-the-github-container-registry)
  * [Build the Image](#build-the-image)
  * [Push the Image to the Registry](#push-the-image-to-the-registry)

## Install Git Hooks

```bash
./init-hooks.sh
```

## Export Required Env Variables

Where:
- (Optional) GIT_PAT: Github Personal Access Token. For reference on creating a [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- OWNER: Github username
- DOCKER_TAG_VERSION_NUMBER: This is the version number the image is going to be tagged with, increment this number when pushing a new version!

Optional: Only required if manually pushing the image to the Github Container Registry
```bash
export GIT_PAT=<GITHUB_PERSONAL_AUTHENTICATION_TOKEN>
```

```bash
export OWNER=<GITHUB_OWNER>
export DOCKER_TAG_VERSION_NUMBER=<DOCKER_TAG_VERSION_NUMBER>
```

## Install Required Dependencies on Host Machine

This is required to pull the repo and invoke the Makefile targets

```bash
apt-get update -y
apt-get upgrade -y
apt-get install git make curl gpg -y
```

## Install docker

If using WSL2, skip this and continue with the [WSL2 - ubuntu distro instructions](#wsl2---ubuntu-distro)

### Ubuntu

This will install Docker and add the user to the docker group

```bash
make install
```

Before proceeding, log out and log back in for the group change to take effect.

---

### WSL2 - ubuntu distro

Follow these instructions to install [Docker Desktop](https://docs.docker.com/desktop/windows/install/)

---

## Optional: Manually building the image and pushing to Github Container Registry

### Login to the Github container registry

This is required to push the image to the Github Container Registry

```bash
echo $GIT_PAT | docker login ghcr.io -u $OWNER --password-stdin
```

### Build the Image

Invoke the build target

This build will take a while, be patient :)

```bash
make build
```

### Push the Image to the Registry

```bash
make push
```

### Running the Image

If you need to run and exec the image for any reason then invoke the following

```bash
make run && make exec
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
