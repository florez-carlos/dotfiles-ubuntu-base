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
    printf "%s\n" " -> Beginning src dependencies URL check: "
    printf "%s\n" ""

    neovim_branch_version="stable"

    jdtls_url="https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz"
    maven_url="https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.tar.gz"
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
    # maven
	curl -L -o /tmp/maven.tar.gz $maven_url
   	# Lombok
	curl -L -o /tmp/lombok.jar  $lombok_url
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
get_src_dependencies
get_npm_dependencies
check_dependencies
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
