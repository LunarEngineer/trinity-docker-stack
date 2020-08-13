FROM debian:buster-slim

LABEL \
maintainer="justin@promise.io" \
version="1.0.0"

# This is the trinitycore repository to clone from
ARG TRINITYCORE_REPO="https://github.com/TrinityCore/TrinityCore"
# SHA hash to buld from
# This was the hash for gaia originally
# ARG TRINITYCORE_HASH="7258d00f932cfde051fecdb14f207f0a2fe5e79"
# This was the most recent commit as of 20200722
ARG TRINITYCORE_HASH="7258d00f932cfde051fecdb14f207f0a2fe5e79"
# Branch to pull
ARG TRINITYCORE_BRANCH="3.3.5"
# This is the database file to pull down code from
ARG TRINITYCORE_TDB="https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.20071/TDB_full_world_335.20071_2020_07_15.7z"
# The home directory of the user
ARG TRINITYCORE_USER_HOME="/root"
# The location to install the source from
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
# The location to install the source into
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
# Install prefix for CMAKE.
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
# Default CMAKE flags
ARG CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=${TRINITYCORE_INSTALL_PREFIX}"
# Should I print lots of stuff out?
ARG BUILD_VERBOSE="true"

# install trinitycore dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        clang \
        cmake \
        git \
        jq \
        libmariadb-dev-compat \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libncurses-dev \
        libboost-all-dev \
        make \
        mariadb-client \
        p7zip-full

WORKDIR ${TRINITYCORE_USER_HOME}

# add the pre-build work
ADD prebuild.sh "${TRINITYCORE_USER_HOME}"
# add the cmake wrapper
ADD cmake.sh "${TRINITYCORE_USER_HOME}"

# run the pre-build work.
RUN /bin/bash "$HOME/prebuild.sh"
# run the cmake wrapper
RUN cd "${TRINITYCORE_SOURCE_DIR}" && \
    mkdir -p "${TRINITYCORE_BUILD_DIR}" && \
    cd "${TRINITYCORE_BUILD_DIR}" && \
    "$HOME/cmake.sh" "${CMAKE_FLAGS}" ../
