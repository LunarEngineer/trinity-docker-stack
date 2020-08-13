FROM trinitycore-base

LABEL \
maintainer="timothy.d.luna@gmail.com" \
version="1.0.0"

# These carry over from the *build* docker file.
# The home directory of the user
ARG TRINITYCORE_USER_HOME="/root"
# The location to install the source from
ARG TRINITYCORE_SOURCE_DIR="${TRINITYCORE_USER_HOME}/TrinityCore"
# The location to install the source into
ARG TRINITYCORE_BUILD_DIR="${TRINITYCORE_SOURCE_DIR}/build"
# Install prefix for CMAKE.
ARG TRINITYCORE_INSTALL_PREFIX="/usr/local"
# Log directory for the authserver
ARG TRINITYCORE_LOG_DIR="/var/log/authserver"
# Should I be talkative?
ARG BUILD_VERBOSE="true"
# How much grunt can I have?
ARG BUILD_JOBS=10

# Tim note 20200308 - These aren't used in the build.
#   Removed for a scream test, extracted to the env file.
# ENV \
# MYSQL_ROOT_PASSWORD_FILE="/run/secrets/mysql_root_password_file" \
# MYSQL_PASSWORD_FILE="/run/secrets/mysql_pass_file" \
# CONNECT_RETRIES=10 \
# RETRY_INTERVAL=8

WORKDIR ${TRINITYCORE_BUILD_DIR}

# build and remove build-time dependencies
RUN \
# build and install
make -j${BUILD_JOBS} VERBOSE=${BUILD_VERBOSE} authserver && \
make -Csrc/server/authserver install && \
# copy the sql files
# Tim note 20200308 - I removed the updates... does this need to go?
#   Removed as a scream test.
# cd ../ && cp \
#     sql/create/create_mysql.sql \
#     sql/base/auth_database.sql \
#     "${TRINITYCORE_USER_HOME}" && \
# cp -r sql/updates "${TRINITYCORE_USER_HOME}" && \
# remove the sources
# cd ../ && rm -r "${TRINITYCORE_SOURCE_DIR}" TrinityCore.tar.gz && \
mkdir -p "${TRINITYCORE_LOG_DIR}" && \
# update the configuration
sed 's|^Updates.EnableDatabases *= *[[:digit:]]|Updates.EnableDatabases = 0|g; \
     s|^Updates.AutoSetup *= *[[:digit:]]|Updates.AutoSetup = 0|g; \
     s|^LogsDir *= *""|LogsDir = "'${TRINITYCORE_LOG_DIR}'"|g;' \
     "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf.dist" > "${TRINITYCORE_INSTALL_PREFIX}/etc/authserver.conf" && \
# remove the dependencies
apt-get purge -y \
    clang \
    cmake \
    curl \
    make \
    p7zip && \
apt-get autoremove -y && \
apt-get clean -y

WORKDIR ${TRINITYCORE_USER_HOME}

EXPOSE 3724/tcp

# copy and set the entrypoint
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["authserver"]
