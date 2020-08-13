#!/usr/bin/env bash

set -e

export TRINITYCORE_HASH="${TRINITYCORE_VERSION:-7258d00f932cfde051fecdb14f207f0a2fe5e79}"
export TRINITYCORE_TDB="${WORLD_DB_RELEASE:-https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.20031/TDB_full_world_335.20031_2020_03_16.7z}"
export CLIENT_DIR="${CLIENT_DIR:-/mnt/gaia_share/Games/wowclient}"

echo "Creating the SQL Backup volume"
docker volume create trinitycore-backup > /dev/null
echo "Loading client Data directory..."
docker volume create trinitycore-data > /dev/null
cat <<SCRIPT | docker run --rm -i -v "$CLIENT_DIR:/client:cached" -v trinitycore-data:/data debian:buster-slim
#!/usr/bin/env bash
for D in dbc maps vmaps mmaps Data; do
    if [ -d /client/\$D ]; then
        echo "Copying \$D to the data volume..."
        cp -rn /client/\$D /data
    fi
done
SCRIPT

echo "Building..."
docker build -t trinitycore-dataserver --build-arg IMPORT_DATABASES 1
docker build -t trinitycore-base --build-arg TRINITYCORE_HASH base
docker build -t trinitycore-authserver authserver
docker build -t trinitycore-worldserver worldserver

exec docker-compose up
