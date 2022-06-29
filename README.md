# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
dev environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the base dependencies then proceed with this repo: 
[Dotfiles](https://gtihub.com/florez-carlos/dotfiles) 

## Installation

### Intall required dependencies on host machine

This is required to pull the repo and invoke the Makefile targets

```bash
apt-get update -y
apt-get upgrade -y
apt-get install git make -y
```

### Define the Personal Authentication Token and login to the registry

```bash
export GIT_PAT={GITHUB_PERSONAL_AUTHENTICATION_TOKEN}
echo $GIT_PAT | docker login ghcr.io -u {OWNER} --password-stdin
```

### Build the image

Invoke the build target and pass the version and owner variables to it,
the version number will correspond to the docker tag version number and
owner the Github owner
e.g  ghcr.io/florez-carlos/dev-env-ubuntu-base-img:1.0.0

This build will take a while, be patient :)

```bash
make build version={DOCKER_TAG_VERSION_NUMBER} owner={OWNER}
```

### Push the image to the registry


```bash
docker push ghcr.io/{OWNER}/dev-env-ubuntu-base-img:{DOCKER_TAG_VERSION_NUMBER}
```

### Optional: running the image

If you need to run and exec the image for any reason then invoke the following

```bash
make run version={DOCKER_TAG_VERSION_NUMBER} owner={OWNER}
make exec
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
