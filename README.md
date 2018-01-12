# icepack continuous integration

This repository contains helper scripts that are used to test the ice sheet modelling library [icepack](https://github.com/icepack/icepack).
Icepack uses a [docker](https://www.docker.com) image containing a firedrake installation for testing with [travis](https://www.travis-ci.org).

### Docker cheat sheet

Build a docker container from a `Dockerfile` in a given directory:

    docker build -t <username>/<container name>:<container version tag> <directory of Dockerfile>

Start a container interactively so you can run commands at a terminal inside it:

    docker run --interactive --tty <container name> bash

Same as above, but make a directory on yuor system visible inside the container:

    docker run --interactive --tty \
        --volume </path/on/host>:</path/on/container> \
        <container name> bash

