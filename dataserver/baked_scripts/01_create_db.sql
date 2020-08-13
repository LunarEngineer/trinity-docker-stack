/*
####################################################################
This script is used by the Docker service to create the databases
####################################################################
*/
-- CREATE USER 'trinity' IDENTIFIED BY 'trinity' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;

GRANT USAGE ON * . * TO 'trinity';

-- This is unnecessary because the world database is created by default
--   in the docker container.
--CREATE DATABASE `world` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE DATABASE `characters` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE DATABASE `auth` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

GRANT ALL PRIVILEGES ON `world` . * TO 'trinity' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON `characters` . * TO 'trinity' WITH GRANT OPTION;

GRANT ALL PRIVILEGES ON `auth` . * TO 'trinity' WITH GRANT OPTION;
