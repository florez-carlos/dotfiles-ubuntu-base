#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

add_ppa() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning Add nodejs ppa: "
    printf "%s\n" ""
    sleep 1
    
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

    printf "%s\n" ""
    printf "%s\n" " -> Beginning Add Azure cli: "
    printf "%s\n" ""
    sleep 1
 
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

    printf "%s\n" ""
    printf "%s\n" " -> Beginning Add Mongo shell ppa: "
    printf "%s\n" ""
    sleep 1
    
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

    printf "%s\n" ""
    printf "%s\n" " -> Beginning Add Python ppa: "
    printf "%s\n" ""
    sleep 1

    add-apt-repository ppa:deadsnakes/ppa

    
    apt-get update -y
}

update() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning update: "
    printf "%s\n" ""
    sleep 1
    apt-get update -y 
    apt-get upgrade -y 
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

    #min_version is not used here
    while IFS='=' read -r dependency min_version
    do
        
        printf "%s" " -> Installing $dependency: "
        
        apt-get install "$dependency" -y 
        
    done < "$dependencies_file"

    printf "%s\n" ""
    printf "%s\n" " -> Beginning APT Dependency check: "
    printf "%s\n" ""
    while IFS='=' read -r dependency min_version
    do

        installed_version="$(dpkg -s "$dependency" | grep '^Version:' | cut -d' ' -f2)"
        dpkg --compare-versions "$installed_version" gt "$min_version"

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

get_ppa_dependencies() {
    
    dependencies_file="${TMP_CONFIG}/ppa-dependencies.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning PPA Dependency Download: "
    printf "%s\n" ""

    while IFS='=' read -r dependency min_version
    do
        
        printf "%s" " -> Installing $dependency: "
        
        apt-get install "$dependency" -y 
        
    done < "$dependencies_file"

    printf "%s\n" ""
    printf "%s\n" " -> Beginning PPA Dependency check: "
    printf "%s\n" ""
    while IFS='=' read -r dependency min_version
    do

        installed_version="$(dpkg -s "$dependency" | grep '^Version:' | cut -d' ' -f2)"
        dpkg --compare-versions "$installed_version" gt "$min_version"

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

    jdtls_url="https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz"
    maven_url="https://dlcdn.apache.org/maven/maven-3/${MAVEN_CURRENT_VERSION}/binaries/apache-maven-${MAVEN_CURRENT_VERSION}-bin.tar.gz"
    lombok_url="https://projectlombok.org/downloads/lombok.jar"
    neovim_url="https://github.com/neovim/neovim.git"
    urls=($jdtls_url $maven_url $lombok_url)
    for url in "${urls[@]}"
    do
	response="$(curl --head --silent --write-out %{http_code} --output /dev/null $url)"
	if [ $response -eq 200 ]
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

    # jdtls
    curl -L -o /tmp/jdtls.tar.gz $jdtls_url 
    tar -xvzf /tmp/jdtls.tar.gz -C $DOT_HOME_LIB/jdtls

    # maven
    curl -L -o /tmp/maven.tar.gz $maven_url
    tar -xvzf /tmp/maven.tar.gz -C $DOT_HOME_LIB/maven

    # Lombok
    curl -L -o /tmp/lombok.jar  $lombok_url
    cp /tmp/lombok.jar $DOT_HOME_LIB/lombok.jar


    #NeoVim
    git clone --depth=1 $neovim_url --branch $neovim_branch_version --single-branch /tmp/neovim
    cd /tmp/neovim
    make CMAKE_BUILD_TYPE=Release
    make install

}

get_npm_dependencies() {


    printf "%s\n" ""
    printf "%s\n" " -> Beginning NPM dependencies download: "
    printf "%s\n" ""

    dependencies_file="${TMP_CONFIG}/npm-dependencies.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning NPM Dependency Download: "
    printf "%s\n" ""

    while IFS='=' read -r dependency min_version
    do
        
        printf "%s" " -> Installing $dependency: "
        
	npm i -g "$dependency"
        
    done < "$dependencies_file"

    printf "%s\n" ""
    printf "%s\n" " -> Beginning NPM Dependency check: "
    printf "%s\n" ""
    while IFS='=' read -r dependency min_version
    do

	installed_version="$(npm list -g | awk -v var=${dependency} -F@ '$0 ~ var { print $2;exit; }')"
        dpkg --compare-versions "$installed_version" gt "$min_version"

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


if [[ $UID != 0 ]]; then
    printf "%s\n" "Please run this script with sudo:"
    printf "%s\n" "sudo $0"
    exit 1
fi

update
get_apt_dependencies
add_ppa
get_ppa_dependencies
get_src_dependencies
get_npm_dependencies
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
