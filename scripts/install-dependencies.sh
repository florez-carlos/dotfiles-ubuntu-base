#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

add_ppa() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning Add neovim ppa: "
    printf "%s\n" ""
    sleep 1
    
    add-apt-repository ppa:neovim-ppa/stable
    apt-get update -y

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
    all_dependencies_count=0
    dependencies_failures_count=0
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning APT Dependency Download: "
    printf "%s\n" ""

    #min_version is not used here
    while IFS='=' read -r dependency min_version
    do
        
        ((++all_dependencies_count))
        printf "%s" " -> Installing $dependency: "
        
        apt-get install "$dependency" -y &> /dev/null
        
        if dpkg -s "$dependency" &> /dev/null
        then

            printf "%s\n" "${color_green}SUCCESS${color_normal}"

        else

            ((++dependencies_failures_count))
            printf "%s\n" "${color_red}FAILED${color_normal}"

        fi
    done < "$dependencies_file"


    if [ $dependencies_failures_count -eq 0 ]
    then
        
        printf "%s\n" ""
        printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies have been installed successfully"

    elif [ $all_dependencies_count -eq 0 ]
    then
        
        printf "%s\n" "${color_yellow}WARNING${color_normal}: No dependencies have been installed"
        exit 1

    elif  [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -eq $all_dependencies_count ]
    then
        
        printf "%s\n" "${color_red}ERROR${color_normal}: All dependencies have failed installation!"
        exit 1

    elif [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -ne $all_dependencies_count ]
    then

        printf "%s\n" "${color_yellow}WARNING${color_normal}: Some dependencies have failed installation"
        exit 1

    fi

    return 1
 
}

get_ppa_dependencies() {
    
    dependencies_file="${TMP_CONFIG}/ppa-dependencies.txt"
    all_dependencies_count=0
    dependencies_failures_count=0
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning PPA Dependency Download: "
    printf "%s\n" ""

    #min_version is not used here
    while IFS='=' read -r dependency min_version
    do
        
        ((++all_dependencies_count))
        printf "%s" " -> Installing $dependency: "
        
        apt-get install "$dependency" -y &> /dev/null
        
        if dpkg -s "$dependency" &> /dev/null
        then

            printf "%s\n" "${color_green}SUCCESS${color_normal}"

        else

            ((++dependencies_failures_count))
            printf "%s\n" "${color_red}FAILED${color_normal}"

        fi
    done < "$dependencies_file"


    if [ $dependencies_failures_count -eq 0 ]
    then
        
        printf "%s\n" ""
        printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies have been installed successfully"

    elif [ $all_dependencies_count -eq 0 ]
    then
        
        printf "%s\n" "${color_yellow}WARNING${color_normal}: No dependencies have been installed"
        exit 1

    elif  [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -eq $all_dependencies_count ]
    then
        
        printf "%s\n" "${color_red}ERROR${color_normal}: All dependencies have failed installation!"
        exit 1

    elif [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -ne $all_dependencies_count ]
    then

        printf "%s\n" "${color_yellow}WARNING${color_normal}: Some dependencies have failed installation"
        exit 1

    fi

    return 1
 
}
check_dependencies() {
    
    dependencies_file="${TMP_CONFIG}/all-dependencies.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning All Dependencies Version Check: "
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
            printf "%s\n" "Proceed with manual installation of $dependency - $min_version or larger and rerun this script"
            exit 1;

        else
            printf "%s\n" "$dependency - $installed_version: ${color_green}PASS${color_normal}"
            continue
        fi


    done < "$dependencies_file"
    
    printf "%s\n" ""
    printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies are of appropriate version"
}

get_src_dependencies() {
	
	printf "%s\n" ""
	printf "%s\n" " -> Beginning src dependencies download: "
	printf "%s\n" ""
    # jdtls
	curl -L -o /tmp/jdtls.tar.gz https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz
    # maven
	curl -L -o /tmp/maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
    # Lombok
    curl -L -o /tmp/lombok.jar https://projectlombok.org/downloads/lombok.jar
}

get_npm_dependencies() {


	printf "%s\n" ""
	printf "%s\n" " -> Beginning NPM dependencies download: "
	printf "%s\n" ""
	npm i -g pyright typescript typescript-language-server

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
check_dependencies
get_src_dependencies
get_npm_dependencies
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
