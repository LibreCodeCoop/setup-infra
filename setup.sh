#!/bin/bash
#Script de pré-instalação para servidores da LibreCode
#Versão: 1.0
#By: Fabrício
apt update && apt upgrade -y && apt autoremove -y && apt clean
apt install -y wget curl git vim

# Docker
curl -fsSL "get.docker.com"| bash
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '">> ~/.bashrc

# Timezone
timedatectl set-timezone America/Sao_Paulo

# Pasta raiz dos projetos
mkdir projects
cd projects

# Nginx proxy
git clone https://github.com/LibreCodeCoop/nginx-proxy
cd nginx-proxy
docker network create reverse-proxy
docker-compose up -d
cd -

# Postgres
cp -R ~/infra/postgres ~/projects/
cd postgres
cp .env.example .env
# Edite o .env colocando valores reais
docker network create postgres
docker-compose up -d
cd -

# Redis
cp -R ~/infra/redis ~/projects/
cd redis
docker network create redis
docker-compose up -d
cd -

# ONLYOFFICE
cp -R ~/infra/onlyoffice ~/projects/
cd onlyoffice
docker network create onlyoffice
docker-compose up -d
cp .env.example .env
# Edite o .env colocando valores reais
cd -

# Nextcloud
git clone https://github.com/LibreCodeCoop/nextcloud-docker
cd nextcloud-docker
mkdir -p volumes/nginx/includes
cp ~/infra/nextcloud/nginx/* volumes/nginx/includes
mkdir -p volumes/cron
cp ~/infra/nextcloud/cron/* volumes/cron/cronfile
cp .env.example .env
# Edite o .env colocando valores reais
docker-compose -f docker-compose.fpm.mysql.yml up -d app
sleep 5
docker-compose -f docker-compose.fpm.mysql.yml up -d
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:system:set default_phone_region BR
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ app:install onlyoffice

# Configuração ONLYOFFICE
mkdir -p volumes/nginx/includes
cp ~/infra/nextcloud/nginx/onlyoffice.conf volumes/nginx/includes/
docker-compose -f docker-compose.fpm.mysql.yml restart web
# OBS: Corrija o domínio antes de executar o comando que segue
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value https://<dominioaqui>/ds-vpath/ onlyoffice DocumentServerUrl
# Informe o JTW Token antes de executar o comando que segue
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value JWT_TOKEN onlyoffice jwt_secret
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value true onlyoffice customizationForcesave
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value false onlyoffice customizationFeedback
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value true onlyoffice customizationCompactHeader
docker-compose -f docker-compose.fpm.mysql.yml exec -u www-data app php occ config:app:set --value false onlyoffice sameTab
