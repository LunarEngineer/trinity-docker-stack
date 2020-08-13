#!/usr/bin/env bash
set -e

# Scrape the MYSQL parameters.
MYSQL_ADMIN_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"root" -p"$(cat $(echo $MYSQL_ROOT_PASSWORD_FILE))")
MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$(cat $(echo $MYSQL_PASSWORD_FILE))")

# Go into the home directory.
cd ~

echo "Checking database connection..."
set +e
for _ in $(seq 1 $CONNECT_RETRIES); do
    mysql ${MYSQL_ADMIN_ARGS[@]} -e "SELECT version();"
    connected=$?
    [ $connected -eq 0 ] && break || sleep $RETRY_INTERVAL
done
[ $connected -ne 0 ] && exit $connected
set -e

# Do some string replacement in the auth server.
echo "Setting database configuration from env..."
MYSQL_CONN_STRING="$MYSQL_HOST;$MYSQL_PORT;$MYSQL_USER;$(cat $(echo $MYSQL_PASSWORD_FILE))"
printf "$MYSQL_CONN_STRING"
cat <<SCRIPT | sed -i -f- "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf"
     s|^LoginDatabaseInfo *= *"[^"]*"|LoginDatabaseInfo = "$MYSQL_CONN_STRING;auth"|g
SCRIPT

# Set workdir to home.
cd ~

exec "$@"

