# Trinity Docker Base Image

This is a base image used to construct both the Authentication and World servers for the Trinity stack.

## TL;DR: Build Arguments

### Source Arguments

* TRINITYCORE_REPO - The URL for the repository you wish to download code from.
* TRINITYCORE_HASH - An SHA hash for the Github repository you're downloading code from.
* TRINITYCORE_BRANCH - A string containing the specific branch you wish to pull code from.
* TRINITYCORE_TDB - The URL for the SQL you wish to generate databases from.

### Build Arguments

You probably don't ever need to mess with any of these unless you're tinkering. If you just want to set up a server, the majority of the arguments are fine as they are.

* TRINITYCORE_USER_HOME - Sets the home directory of the trinity core user.
* TRINITYCORE_SOURCE_DIR - Sets the location to put the source code.
* TRINITYCORE_BUILD_DIR - Sets the location to create the build directory.
* TRINITYCORE_INSTALL_PREFIX - Sets the location to install the final code.
* CMAKE_FLAGS - Used to run CMAKE.
* BUILD_VERBOSE - Prints the variables during the build process.

## What Exactly Does It Do?

It downloads a specific version of the the codebase for the Trinity Core and a specific set of SQL for the Trinity Core databases.

It sets up everything during the build of this image so that the Authentication and World servers can build.

## How Exactly Does It Do It?

After setting all environment variables in the Dockerfile it runs the prebuild shell script to fetch the correct source code and SQL files.

### Source Code

This image uses the repository, branch, and SHA hash you specify to pull down the code using a git checkout command into TRINITYCORE_SOURCE_DIR.

It uses the TDB URL you specify to pull down the .7z SQL files and unzip them into TRINITYCORE_SOURCE_DIR/sql.

Then it runs cmake on the source code to prepare it for compile using any extra flags passed with CMAKE_FLAGS.

## Possible Future Improvements

1. Alpine Docker images will likely reduce the size of this image tremendously.
