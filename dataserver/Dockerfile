FROM mariadb:10.5

LABEL \
maintainer="timothy.david.luna@gmail.com" \
version="1.0.0"

RUN apt-get update && \
    apt-get install -y \
        libreadline-dev \
        p7zip-full \
        jq \
        curl
# This will create the databases if requested, otherwise it will
#   ingest a SQL dump. If it ingests a SQL dump then it will do
#   nothing except for ingest the sql dump.
# Note that this can be used for any arbitrary SQL
# Currently this is hard coded to eat certain SQL files in the
#   database populater script. Check in there to see for sure
#   what's going on.
ARG CREATE_DATABASES=0
ARG IMPORT_DATABASES=1
ARG CUSTOM_SQL=0
ARG TRINITY_CORE_TDB=""

# There needs to be a root user.
ENV \
MYSQL_ROOT_PASSWORD_FILE="/run/secrets/mysql_root_password_file" \
MYSQL_USER="trinity" \
MYSQL_PASSWORD_FILE="/run/secrets/mysql_pass_file" \
MYSQL_DATABASE='world' \
MYSQL_HOST="db" \
MYSQL_PORT="3306"

COPY database_populater.sh /database_populater.sh
COPY baked_scripts/* /baked_scripts/
COPY custom_scripts/* /custom_scripts/

RUN /database_populater.sh

EXPOSE 3306/tcp
