FROM trinitycore-base

LABEL \
maintainer="timothy.d.luna@gmail.com" \
version="1.0.0"

# The home directory of the user
ARG TRINITYCORE_USER_HOME="/root"
# The location to install the source from
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
# The location to install the source into
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
# Install prefix for CMAKE.
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
# Should I print lots of stuff out?
ARG BUILD_VERBOSE="true"
# How many cores should I use to build?
ARG BUILD_JOBS=10
# Should I build the map extractors?
ARG BUILD_TOOLS=1
# Where is the binary folder?
ARG TRINITYCORE_BIN_DIR="${TRINITYCORE_INSTALL_PREFIX}/bin"
# Where is the mapped volume of data going to be?
ARG TRINITYCORE_DATA_DIR="${TRINITYCORE_INSTALL_PREFIX}/data"
# Where should logs be dumped?
ARG TRINITYCORE_LOG_DIR="/var/log/worldserver"

# These we *also* need at build time.
ENV \
TRINITYCORE_INSTALL_PREFIX="${TRINITYCORE_INSTALL_PREFIX}" \
TRINITYCORE_DATA_DIR="${TRINITYCORE_DATA_DIR}" \
EXTRACT_DATA="${BUILD_TOOLS}"

WORKDIR ${TRINITYCORE_BUILD_DIR}

# Copy in the server configuration file.

COPY worldserver.conf /usr/local/etc/worldserver.conf

# build and remove build-time dependencies
RUN \
# build and install
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} worldserver && \
make -Csrc/server/worldserver install && \
if [ "${BUILD_TOOLS}" = "1" ]; then \
	make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} src/tools && \
	make -Csrc/tools install; \
fi && \
cd ../../ && \
mkdir -p "${TRINITYCORE_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^Console.Enable *= *[[:digit:]]|Console.Enable = 0|g; \
     s|^LogsDir *= *""|LogsDir = "'${TRINITYCORE_LOG_DIR}'"|g; \
     s|^Ra.Enable *= *[[:digit:]]|Ra.Enable = 1|g;' \
     "${TRINITYCORE_INSTALL_PREFIX}/etc/worldserver.conf.dist" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    make && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITYCORE_USER_HOME}

VOLUME ${TRINITYCORE_DATA_DIR}

EXPOSE 3443/tcp
EXPOSE 8085/tcp

# copy and set the entry point
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["worldserver"]
