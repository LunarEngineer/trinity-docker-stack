#!/usr/bin/env bash
set -e


extract_7z_archives() {
  # Pay attention to where you're supposed to see files
  declare path="$1"
  # Then push that on to the stack
  pushd "$path"
  (
    shopt -s nullglob
    if declare zips=("${path%/}"/*.7z) && [[ -n "${zips[@]}" ]]; then
      zip=""
      for zip in "${zips[@]}"; do
        7z x -y "$zip"
      done
    fi
    shopt -u nullglob
  )
  popd
}


get_newest_tdb_url() {
  # This is a bastardization of the code @
  # https://github.com/jackpoz/TrinityCoreCron/blob/3.3.5-TDB/release-tdb.sh#L49
  # to download the *newest* trinity core TDB files.
  curl -s https://api.github.com/repos/TrinityCore/TrinityCore/releases | \
    jq 'map(select(.tag_name|startswith("TDB335"))) | sort_by(.created_at) | reverse | .[0]' | \
    jq -r '.assets | map(select(.name|endswith("7z"))) | .[0].browser_download_url'

}


get_tdb_url() {
  # TODO: Make sure this works!
  # All of the previous work is refactored into:
  # Is there a trinitycore_tdb version specified?
  # If so, use that link, if not, get the latest.
  if [ -z "$TRINITYCORE_TDB" ] ;
  then
    echo "Warning: No TDB version passed, downloading most recent release." 1>&2
    TRINITYCORE_TDB=$(get_newest_tdb_url)
  fi
  mkdir db_create
  printf '\tDownloading trinity TDB file from: %s\n' "$TRINITYCORE_TDB"
  curl -L --progress-bar -o "/db_create/${TRINITYCORE_TDB##*/}" "$TRINITYCORE_TDB"
  printf '\tUnpacking the TDB file\n'
  extract_7z_archives "/db_create/"
  printf '\tCleaning up TDB file\n'
  rm /db_create/*.7z
  # This needs to go up front in the stupid db create sql script.
  sed -i '1 i\USE world;' $(ls /db_create/*.sql)
}



# Should I create databases?
if [ "$CREATE_DATABASES" = "1" ]; then
    # We need to go get the TDB
    printf "Downloading databases...\n"
    get_tdb_url
    printf "Creating databases...\n"
    cp /baked_scripts/01_create_db.sql /docker-entrypoint-initdb.d
    cp /db_create/*.sql /docker-entrypoint-initdb.d/01_create_world.sql
fi

# Should I create databases?
if [ "$IMPORT_DATABASES" = "1" ]; then
    if [ -z "/baked_scripts/00_import_db.sql" ] ;
    then
        printf "No database file passed. This is most likely going to die."
    else
        printf "Importing databases...\n"
        cp /baked_scripts/01_create_db.sql /docker-entrypoint-initdb.d
        cp /baked_scripts/02_import_db.sql /docker-entrypoint-initdb.d
    fi
fi

# Is there custom sql to run?
if [ "$CUSTOM_SQL" = "1" ]; then

    printf "Importing custom sql files...\n"
    for sql_file in /custom_scripts/*; do
        printf "\tCustom SQL: ${sql_file##*/}\n"
        cp "/custom_scripts/${sql_file##*/}" "/docker-entrypoint-initdb.d/99_${sql_file##*/}"
    done
fi


exec "$@"

