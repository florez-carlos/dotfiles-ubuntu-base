#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
# color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

arch=$(dpkg --print-architecture)
read -ra PYTHON_VERSIONS <<< "${PYTHON_VERSIONS}"


update() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning update: "
    printf "%s\n" ""
    apt update -y 
    apt upgrade -y --fix-missing
    apt install -y unminimize man-db

    if ! yes Y | unminimize
    then
        printf "%s\n" "${color_red}ERROR${color_normal}: An error has occurred updating, halting..."
        exit 1
    fi
    
}

get_apt_dependencies() {
    
    dependencies_file="${TMP_CONFIG}/apt-dependencies.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning APT Dependency Download: "
    printf "%s\n" ""

    mapfile -t pkgs < <(cut -d= -f1 "$dependencies_file" | sort -u)

    printf " -> Installing %d packages\n" "${#pkgs[@]}"
    apt install -y "${pkgs[@]}"
    if ! apt install -y "${pkgs[@]}"
    then
        printf "%s\n" "${color_red}ERROR${color_normal}: APT dependency installation failed, halting..."
        exit 1
    fi

    printf "%s\n" ""
    printf "%s\n" " -> Beginning APT Dependency check: "
    printf "%s\n" ""
    while IFS='=' read -r dependency min_version
    do

        installed_version="$(dpkg -s "$dependency" | grep '^Version:' | cut -d' ' -f2)"

        if ! dpkg --compare-versions "$installed_version" gt "$min_version"
        then
            printf "%s\n" "$dependency - $installed_version: ${color_red}FAIL${color_normal}"
            printf "%s\n" ""
            printf "%s\n" "${color_red}ERROR${color_normal}: $dependency installed version: $installed_version but minimum required: $min_version"
            exit 1;

        else
            printf "%s\n" "$dependency - $installed_version: ${color_green}PASS${color_normal}"
            continue
        fi
    done < "$dependencies_file"

}

get_src_dependencies() {
	
    printf "%s\n" ""
    printf "%s\n" " -> Beginning src dependencies URL check: "
    printf "%s\n" ""

    neovim_branch_version="stable"
    neovim_url="https://github.com/neovim/neovim.git"
    python_url="https://github.com/python/cpython.git"
    case "$arch" in
    x86_64|amd64)
        awscli_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
        ;;
    aarch64|arm64)
        awscli_url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
        ;;
    *)

        printf "%s\n" "${color_red}ERROR${color_normal}: Unsupported architecture: ${arch}"
        exit 1
        ;;
    esac
    urls=("$neovim_url" "$python_url")
    for url in "${urls[@]}"
    do
	response="$(curl --head --silent --location --write-out "%{http_code}" --output /dev/null "$url")";
	if [ "$response" -eq 200 ]
	then
	    printf "%s\n" "${color_green}URL VALID${color_normal}: ${url}"
	else
            printf "%s\n" "${color_red}ERROR${color_normal}: ${url} is not valid. http code: ${response}"
            printf "%s\n" "${color_red}ABORTING${color_normal}"
	    exit 1
	fi
	sleep 1
    done

    printf "%s\n" ""
    printf "%s\n" " -> Beginning src dependencies download: "
    printf "%s\n" ""


    for python_version in "${PYTHON_VERSIONS[@]}"; do
        printf "%s\n" ""
        printf "%s\n" " -> Beginning python${python_version} install: "
        printf "%s\n" ""
        sleep1
        
        location="/tmp/python-${python_version}"

        git clone --depth=1 $python_url --branch "$python_version" --single-branch "$location"
        cd "$location" || { echo "${color_red}ERROR${color_normal}: Could not cd into ${location}"; exit 1; }
        ./configure --enable-optimizations
        make
        make altinstall
    done

    # Remove symlink from installed python to preserve link to system python /usr/bin/python3
    rm -f /usr/local/bin/python3

    # awscli
    curl -L -o /tmp/awscliv2.zip "$awscli_url"
    unzip /tmp/awscliv2.zip -d /tmp/
    # shellcheck source=/dev/null
    sudo /tmp/aws/install
    aws configure set cli_pager ""

    #NeoVim
    git clone --depth=1 $neovim_url --branch $neovim_branch_version --single-branch /tmp/neovim
    cd /tmp/neovim || { echo "${color_red}ERROR${color_normal}: Could not cd into /tmp/neovim"; exit 1; }
    make CMAKE_BUILD_TYPE=Release
    make install

    #Removal
	cd / || exit 1

    for version in "${PYTHON_VERSIONS[@]}"; do
        rm -rf "/tmp/python-${version}"
    done
    
    rm /tmp/awscliv2.zip
    rm -r /tmp/aws
    rm -rf /tmp/neovim

}

get_pip_dependencies() {

    for python_version in "${PYTHON_VERSIONS[@]}"; do
        version="${python_version#v}" # strip leading 'v' if present
        minor="${version%.*}"  # strips patch: 3.11.6 -> 3.11
        /usr/local/bin/python"${minor}" -m pip install --no-cache-dir --upgrade pip
        /usr/local/bin/python"${minor}" -m pip install --no-cache-dir setuptools wheel pynvim ruff build twine vermin
    done

    ln -sf /usr/local/bin/python"${PYTHON_DEFAULT}" /usr/local/bin/python
    ln -sf /usr/local/bin/pip"${PYTHON_DEFAULT}" /usr/local/bin/pip
    
}

set_locale() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning set locale: "
    printf "%s\n" ""

    locale-gen en_US.UTF-8
    locale-gen en_US

}


if [[ $UID != 0 ]]; then
    printf "%s\n" "Please run this script with sudo:"
    printf "%s\n" "sudo $0"
    exit 1
fi

update
get_apt_dependencies
set_locale
get_src_dependencies
get_pip_dependencies
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
