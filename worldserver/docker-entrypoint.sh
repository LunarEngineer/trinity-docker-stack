#!/usr/bin/env bash
set -e

# Scrape the MYSQL parameters.
MYSQL_ADMIN_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"root" -p"$(cat $(echo $MYSQL_ROOT_PASSWORD_FILE))")
MYSQL_ARGS=(-h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$(cat $(echo $MYSQL_PASSWORD_FILE))")

# run inside a mounted volume, writing extracted
# files to the host if they're not already present
if [ "$EXTRACT_DATA" = "1" ]; then
    cd "$TRINITYCORE_DATA_DIR"

    echo "Extracting client data..."

    if ! [ -d dbc ]; then
        mapextractor
    else
        echo "dbc and maps already extracted, skipping"
    fi

    if ! [ -d vmaps ]; then
        vmap4extractor
        vmap4assembler
    else
        echo "vmaps already extracted, skipping"
    fi

    if ! [ -d mmaps ]; then
        mmaps_generator
    else
        echo "mmaps already extracted, skipping"
    fi
fi

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

echo "Setting database configuration from env..."
MYSQL_CONN_STRING="$MYSQL_HOST;$MYSQL_PORT;$MYSQL_USER;$(cat $(echo $MYSQL_PASSWORD_FILE))"
cat <<SCRIPT | sed -i -f- "${TRINITYCORE_INSTALL_PREFIX}/etc/worldserver.conf"
     s|^DataDir *= *"\."|DataDir = "${TRINITYCORE_DATA_DIR}"|g
     s|^LoginDatabaseInfo *= *"[^"]*"|LoginDatabaseInfo = "$MYSQL_CONN_STRING;auth"|g
     s|^WorldDatabaseInfo *= *"[^"]*"|WorldDatabaseInfo = "$MYSQL_CONN_STRING;world"|g
     s|^CharacterDatabaseInfo *= *"[^"]*"|CharacterDatabaseInfo = "$MYSQL_CONN_STRING;characters"|g
SCRIPT


cd ~

exec "$@"

