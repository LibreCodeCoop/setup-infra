#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER nextcloud WITH PASSWORD '$NEXTCLOUD_DB_PASSWORD';
    CREATE DATABASE nextcloud;
    GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;

    CREATE USER onlyoffice WITH PASSWORD '$ONLYOFFICE_DB_PASSWORD';
    CREATE DATABASE onlyoffice;
    GRANT ALL PRIVILEGES ON DATABASE onlyoffice TO onlyoffice;
EOSQL