# Trinity Docker Authentication Server Image

This is an image used to run the Authentication server of the Trinity stack.

## TL;DR: Build Arguments

### Source Installation Arguments

* TRINITYCORE_USER_HOME - The home directory where the authentication server is to be run from.
* TRINITYCORE_SOURCE_DIR - The location of the source code.
* TRINITYCORE_BUILD_DIR - The build folder where the build artifacts were dumped into during the base build.
* TRINITYCORE_INSTALL_PREFIX - The directory where the authentication server is to be installed into.
* TRINITYCORE_LOG_DIR - The directory for the authentication server to dump logs into.
* BUILD_JOBS - An integer telling make how parallelized it can be.
* BUILD_VERBOSE - A boolean flag telling the make routine to be quiet or not.

## What Exactly Does It Do?

It compiles the Authentication server for the Trinity stack dependent on the choices that you made for the build.

When it's done compiling it will be able to just run whenever it's called.

## How Exactly Does It Do It?

During the build it runs make for the authentication server. That's... really about it. In the entry point script it sets down a 'wait' routine that will ping the database until it's responsive. When the data server responds to communications then the authentication server will run the Trinity core authserver routine.

## Possible Future Improvements

1. Alpine Docker images will likely reduce the size of this image tremendously.
2. Add in an authentication server configuration file, like the world server.

