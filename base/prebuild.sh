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
    TRINITYCORE_TDB = get_newest_tdb_url
  fi

  # Now check to ensure the local SQL directory exists.
  # If it doesn't, then create it.
  if [[! -d "$TRINITYCORE_SOURCE_DIR/sql" ]]; then
    mkdir -p "$TRINITYCORE_SOURCE_DIR/sql"
  fi
  printf '\tDownloading trinity TDB file from: %s\n' "$TRINITYCORE_TDB"
  curl -L --progress-bar -o "$TRINITYCORE_SOURCE_DIR/sql/${TRINITYCORE_TDB##*/}" "$TRINITYCORE_TDB"
  extract_7z_archives "$TRINITYCORE_SOURCE_DIR/sql"
}


get_source() {
  # For simplicity just go pull the repo and hash passed.
  #   This assumes these values are filled. It will break if they're not.
  if [ -z "$TRINITYCORE_REPO" ] ;
  then
    echo "Error: No repository for the codebase specified." 1>&2
    exit 63
  fi
  if [ -z "$TRINITYCORE_HASH" ] ;
  then
    echo "Error: No SHA hash for the codebase specified." 1>&2
    exit 64
  fi 
  printf "Pulling down Trinity Core source...\n"
  git clone \
    --branch "$TRINITYCORE_BRANCH" \
    "$TRINITYCORE_REPO" \
    "$TRINITYCORE_SOURCE_DIR"
  cd "$TRINITYCORE_SOURCE_DIR"
  git checkout "$TRINITYCORE_HASH"

}


main() {
  # Report the status of all of the build variables.
  if [ "$BUILD_VERBOSE" = true ] ; then
    printf 'Build Variables and Environment for the base image:\n'
    printf '\tTRINITYCORE_REPO: %s\n' "$TRINITYCORE_REPO"
    printf '\tTRINITYCORE_HASH: %s\n' "$TRINITYCORE_HASH"
    printf '\tTRINITYCORE_BRANCH: %s\n' "$TRINITYCORE_BRANCH"
    printf '\tTRINITYCORE_TDB: %s\n' "$TRINITYCORE_TDB"
    printf '\tTRINITYCORE_USER_HOME: %s\n' "$TRINITYCORE_USER_HOME"
    printf '\tTRINITYCORE_SOURCE_DIR: %s\n' "$TRINITYCORE_SOURCE_DIR"
    printf '\tTRINITYCORE_BUILD_DIR: %s\n' "$TRINITYCORE_BUILD_DIR"
    printf '\tTRINITYCORE_INSTALL_PREFIX: %s\n' "$TRINITYCORE_INSTALL_PREFIX"
    printf '\tCMAKE_FLAGS: %s\n' "$CMAKE_FLAGS"
  fi
  # Go get the source code
  get_source
  # Go get the TDB file
  get_tdb_url
}

main "$@"