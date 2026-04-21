# Dotfiles Ubuntu Base

Base Ubuntu image with the necessary system dependencies to create a containerized 
development environment.

This is the first step in creating a containerized dev environment, if you do
not need to modify the system level dependencies then proceed with this repo: 
[Dotfiles](https://github.com/florez-carlos/dotfiles) 

## Table of Contents

* [Development](#development)
  * [Clone Repo](#clone-repo)
  * [Update submodules](#update-submodules)
  * [Install Git Hooks](#install-git-hooks) 
  * [Update Dependencies](#update-dependencies) 

## Development
> [!NOTE]
> Development for this repo requires use of the [Dotfiles](https://github.com/florez-carlos/dotfiles)
containerized development environment

### Clone Repo

```bash
cd $HOME/workspace
git clone --recurse-submodules -j8 git@github.com:florez-carlos/dotfiles-ubuntu-base.git
cd dotfiles-ubuntu-base
```

### Update Submodules 

Ensure to update the lib submodules before releasing a new update

```bash
git submodule sync
git submodule update --remote --merge
```

### Install Git Hooks

This will setup shellcheck for scripts and commit message verification

```bash
./init-hooks.sh
```

### Update Dependencies

These dependencies must be updated on any new release
- Maven (Dockerfile)
- JDTLS (Dockerfile)
- Python (install-dependencies.sh) - Optional

---

## License
[GNU AGPLv3](https://github.com/florez-carlos/dotfiles-ubuntu-base/blob/main/LICENSE)
