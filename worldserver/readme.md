# Trinity Docker World Server

Build and run the Trinity Core World server.

## TL;DR: Build Arguments

### Source Code Install Arguments

* TRINITYCORE_USER_HOME - The home directory where the world server is to be run from.
* TRINITYCORE_SOURCE_DIR - The location of the source code.
* TRINITYCORE_BUILD_DIR - The build folder where the build artifacts were dumped 
* TRINITYCORE_INSTALL_PREFIX - The directory where the world server is to be installed into.
* TRINITYCORE_BIN_DIR - The directory of the binary folder for the Trinity core install.
* TRINITYCORE_LOG_DIR - The directory for the world server to dump logs into.
* BUILD_VERBOSE - Whether or not the make routine should be quiet.
* BUILD_JOBS - An integer saying how parallelized should the compile run.

### Map Extraction Tools Install Arguments

* TRINITYCORE_DATA_DIR - The directory to look for extracted maps. Also a mapped volume.
* BUILD_TOOLS - Whether or not to make the tools like the map extractors.
* EXTRACT_DATA - Whether to run the map extractors.

## What Exactly Does It Do?

This simply builds the world server. In the entry point script it also checks to see if you need maps unpacked and does that as well, using a mounted volume if supplied.

During the build it also copies in a template worldserver.conf file into which some simple string substitution is made.

## How Exactly Does It Do It?

During the installation for the source code it builds the world server by default. If the flag BUILD_TOOLS is set then it will build the map extractors as well.

When it runs the entry point script it will check to see if folders exist already for the maps in the data directory. If they don't then it will run the map extractors.

When it's done with that it kicks off a 'wait' routine that pings the database. When it can connect then it runs the worldserver executable.

## Possible Future Improvements

1. Alpine linux.
2. Move the map extraction components to a separate docker service during the build.