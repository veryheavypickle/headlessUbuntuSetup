#!/bin/bash

main() {
	sudo apt upgrade -y
	sudo apt update
	
	installPackages
	installMySQL
	installDocker
	sudo apt autoremove
}

installPackages() {
	sudo apt install lm-sensors -y  # command 'sensors' to check cpu temps
	sudo apt install stress -y
}

installDocker() {
	# install docker
	# according to https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
	sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
	apt-cache policy docker-ce
	sudo apt install docker-ce -y
	# make sudoless execution of docker stuff
	sudo usermod -aG docker ${USER}
	su - ${USER}

	sudo apt install docker-compose -y
}

installMySQL() {
	sudo apt install mysql-server
	# https://phoenixnap.com/kb/mysql-remote-connection to allow remote connection2
	# to uninstall https://www.linuxshelltips.com/completely-uninstall-mysql-server-in-ubuntu/
	# https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04
}

main
