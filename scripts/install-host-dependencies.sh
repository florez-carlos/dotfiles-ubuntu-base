#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

install_docker() {

	mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo -H gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \ "deb [arch=$(dpkg --print-architecture) \
	signed-by=/etc/apt/keyrings/docker.gpg] \
	https://download.docker.com/linux/ubuntu \
  	$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update -y
	apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
	docker run hello-world
	adduser ${USER} docker

}


if [[ $UID != 0 ]]; then
    printf "%s\n" "${color_red}ERROR:${color_normal}Please run this script with sudo"
    exit 1
fi

install_docker
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
