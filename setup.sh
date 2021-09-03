#!/bin/bash
#Script de pré-instalação para servidores da LibreCode
#Versão: 1.0
#By: Fabrício
apt update && apt upgrade -y && apt autoremove -y && apt clean
apt install -y wget curl git 
curl -fsSL "get.docker.com"| bash
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '">> ~/.bashrc

