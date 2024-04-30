# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
development environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the system level dependencies then proceed with this repo: 
[Dotfiles](https://github.com/florez-carlos/dotfiles) 

> [!NOTE]
> Installation is supported only for the following: 
> - Ubuntu 20.04+ (amd64)

## Table of Contents

* [Installation](#installation)
  * [Install Required Dependencies on Host Machine](#install-required-dependencies-on-host-machine)
  * [Clone the repo with recurse submodules](#clone-the-repo-with-recurse-submodules)  
  * [Export Required Env Variables](#export-required-env-variables)
  * [Install Docker](#install-docker)
* [Local Build](#local-build)
  * [Build the local image](#build-the-local-image)
  * [Execute the local image](#execute-the-local-image)
* [Remote Build](#remote-build)
  * [Login to the Github Container Registry](login-to-the-github-container-registry)
  * [Build the remote Image](#build-the-remote-image)
  * [Push the remote image to the Registry](#push-the-remote-image-to-the-registry)
* [Development](#development)
  * [Clone the repo in workspace with recurse submodules](#clone-the-repo-in-workspace-with-recurse-submodules)
  * [Install Git Hooks](#install-git-hooks) 


## Installation
> [!Note]
> Skip installation if Dotfiles is already installed and proceed to [Development](#development)

### Install Required Dependencies on Host Machine

This is required to pull the repo and invoke the Makefile targets

```bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install git make curl gpg -y
```

### Clone the repo with recurse submodules

```bash
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles-ubuntu-base.git
cd dotfiles-ubuntu-base
```

### Export Required Env Variables

Where:
- GIT_USER_USERNAME: Github username
- (Optional) GIT_PAT: Github Personal Access Token. For reference on creating a [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

> [!NOTE]
> :warning: Replace the brackets with the appropriate content

```bash
export GIT_USER_USERNAME=<GITHUB USERNAME>
```
GIT_PAT is only required if manually pushing the image to the Github Container Registry
```bash
export GIT_PAT=<GITHUB PERSONAL AUTHENTICATION TOKEN>
```

### Install docker

This will install Docker and add the user to the docker group

```bash
make install
```

Log out for the group change to take effect

```bash
sudo pkill -u username
```

---

## Local build
> [!NOTE]
> This step is only required if needing to build the image locally for testing or any other reason

### Build the local image

Invoke the build target with a custom REGISTRY argument

This build will take a while, be patient :)

```bash
make build REGISTRY=do-not-push
```

### Execute the local image

```bash
make run && make exec
```

---

## Remote Build

> [!NOTE]
> Project is already configured to automatically build on a new release

#### Login to the Github container registry

This is required to push the image to the Github Container Registry

```bash
echo $GIT_PAT | docker login ghcr.io -u $GIT_USER_USERNAME --password-stdin
```

#### Build the remote image

Invoke the build target

This build will take a while, be patient :)

```bash
make build
```

#### Push the remote image to the registry

```bash
make push
```
---

## Development
> [!NOTE]
> :warning: Active development of this repo requires use of the [Dotfiles](https://github.com/florez-carlos/dotfiles)
containerized development environment

### Clone the repo in workspace with recurse submodules

```bash
cd $HOME/workspace
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles-ubuntu-base.git
cd dotfiles
```

### Install Git Hooks

This will setup shellcheck for scripts and commit message verification

```bash
./init-hooks.sh
```
---

## License
[MIT](https://choosealicense.com/licenses/mit/)
