# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
development environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the system level dependencies then proceed with this repo: 
[Dotfiles](https://gtihub.com/florez-carlos/dotfiles) 

The following installation instructions support:

- Ubuntu 20.04+

> [!NOTE]
> Active development of this repo requires use of the [Dotfiles](https://github.com/florez-carlos/dotfiles)
containerized development environment

## Table of Contents

* [Install Git Hooks](#install-git-hooks)
* [Export Required Env Variables](#export-required-env-variables)
* [Install Required Dependencies on Host Machine](#install-required-dependencies-on-host-machine)
* [Install Docker](#install-docker)
  * [Ubuntu](#ubuntu)
* [Optional - Manually building the image and pushing to Github Container Registry](#optional---manually-building-the-image-and-pushing-to-github-container-registry)
  * [Login to the Github Container Registry](login-to-the-github-container-registry)
  * [Build the Image](#build-the-image)
  * [Push the Image to the Registry](#push-the-image-to-the-registry)

## Install Git Hooks

```bash
./init-hooks.sh
```

## Export Required Env Variables

Where:
- GIT_USER_USERNAME: Github username
- (Optional) GIT_PAT: Github Personal Access Token. For reference on creating a [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

> [!Note]
> GIT_USER_USERNAME should already be defined if using Dotfiles
```bash
export GIT_USER_USERNAME=<GITHUB USERNAME>
```

```bash
#Optional: Only required if manually pushing the image to the Github Container Registry
export GIT_PAT=<GITHUB PERSONAL AUTHENTICATION TOKEN>
```

## Install Required Dependencies on Host Machine

This is required to pull the repo and invoke the Makefile targets

```bash
apt-get update -y
apt-get upgrade -y
apt-get install git make curl gpg -y
```

## Install docker

### Ubuntu

This will install Docker and add the user to the docker group

```bash
make install
```

Log out for the group change to take effect

```bash
sudo pkill -u username
```

---

## Optional - Manually building the image and pushing to Github Container Registry

### Login to the Github container registry

This is required to push the image to the Github Container Registry

```bash
echo $GIT_PAT | docker login ghcr.io -u $GIT_USER_USERNAME --password-stdin
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
