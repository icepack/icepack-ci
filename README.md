# icepack continuous integration

This repository contains scripts to help with continuous integration and testing of the ice sheet modelling library [icepack](https://github.com/icepack/icepack) using [travis](https://www.travis-ci.org).
The main dependency for icepack is the finite element modeling library [firedrake](https://www.firedrakeproject.org), which is fairly time-consuming to build.
Rather than recompile firedrake and its dependencies every time we need to test a new commit to the icepack repository, we instead use a [docker](https://www.docker.com) image with firedrake already built.
This repository contains the scripts for building this docker image.
If you want to use the docker image, you can download it from [DockerHub](https://hub.docker.com/r/icepack/firedrake/) instead of building it yourself.

Currently, the docker image is used to facilitate testing the icepack library.
The same infrastructure could also be used to:

* run the tests to check for code coverage as well as correctness
* run benchmarks and check for performance regressions
* update the icepack documentation


### Docker cheat sheet

Build a docker container from a `Dockerfile` in a given directory:

    docker build -t <username>/<container name>:<container version tag> <directory of Dockerfile>

Start a container interactively so you can run commands at a terminal inside it:

    docker run --interactive --tty <container name> bash

Same as above, but sync a directory on your system with a directory in the container:

    docker run --interactive --tty \
        --volume </path/on/host>:</path/on/container> \
        <container name> bash

