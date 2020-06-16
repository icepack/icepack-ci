# icepack continuous integration

This repository contains scripts to help with continuous integration and testing of the ice sheet modelling library [icepack](https://github.com/icepack/icepack) using [CircleCI](https://circle-ci.org).


### Rationale

The main dependency for icepack is the finite element modeling library [firedrake](https://www.firedrakeproject.org), which is fairly time-consuming to build.
Rather than recompile firedrake and its dependencies every time we need to test a new commit to the icepack repository, we instead use a [docker](https://www.docker.com) image with firedrake already built.
This repository contains the scripts for building this docker image.
If you want to use the Docker image, you can download it from [DockerHub](https://hub.docker.com/r/icepack/) instead of building it yourself by running

    docker pull icepack/firedrake-python3.8:<tag>

where `<tag>` is the version of the image.

Currently, the docker image is used to facilitate correctness testing and coverage checking for the icepack library.
The same infrastructure could also be used to:

* run benchmarks and check for performance regressions
* update the icepack documentation


### Versioning

This repo builds two docker images using python-3.6 and python-3.8.
These are the oldest and newest supported versions of python.
The purpose of testing on an old version of python is to keep from using fancy new features (like assignment expressions) that not all users will have.
The purpose of testing on a new version of python is so that we can remove usage of language or library or language features that will soon be deprecated.

The versions of Firedrake and all its dependencies are pinned to specific commit hashes that are known to work.
The commit hashes are all specified in the file `package-branches`.
These commit hashes are then passed to the Firedrake install script when the Docker images are built.
The Firedrake install script can build specific versions of a set of key dependencies (loopy, UFL, and so forth), but not the dependencies of dependencies.
So this approach partly helps with reproducibility but is not a complete solution.


### Docker cheat sheet

##### Building and running

Build a docker image from a `Dockerfile` in a given directory:

    docker build --tage <username>/<image name>:<image version tag> <directory of Dockerfile>

Start a container interactively so you can run commands at a terminal inside it:

    docker run --interactive --tty <image name> bash

##### Sharing files

Same as above, but sync a directory on your system with a directory in the container:

    docker run --interactive --tty \
        --volume </path/on/host>:</path/on/container> \
        <image name> bash

##### Jupyter

To run a Jupyter notebook server from inside a container, you need to forward ports from the container to the host using the `publish` argument:

    docker run --interactive --tty \
        --publish 8888:8888 <image name> bash

From inside the container, you also have to pass a few different arguments when starting the notebook server:

    jupyter notebook --ip 0.0.0.0 --no-browser

The server will print a bunch of things, at the end of which will be a URL that starts with `http://127.0.0.1:8888/?token=<very long hex string>`.
If you paste that URL into your browser you should have access from your host system to the notebook server that's now running in the container.
You can replace 8888 with the port number of your choice.
You might need to do that if, for example, you have another notebook server running on your host system using port 8888, which the container does not (and cannot!) know about.

##### Introspection and debugging

The commands to list the docker images and containers on your system are, respectively,

    docker image ls
    docker container ls

By default, these commands will not show intermediate images or stopped containers; you can see these by appending the `--all` flag.

Sometimes a build will fail at the installation of some package, and the installer for that package will write the reason why to a log file.
But since the build failed, you have no way of accesssing the log file to find out why the build failed!
When this happens, you can look for the hash of the intermediate image in the terminal output from `docker build`.
Then you can use `docker commit` to make give a name to the image at that failing build stage.
Finally you can start a container from the failing stage to recover the log file.
See this [forum post](https://forums.docker.com/t/how-to-debug-build-failures/7049/3) for more detail.

##### Saving space

A typical docker image can be 2GB or more, and even stopped containers take up disk space.
The command

    docker system prune

will clean up anything that's obviously unused.
The command to manually remove a docker image is

    docker image rmi <image name>:<image version tag>

The prune command won't remove images that you've specifically created yourself by a prior call to `docker build`, so to reclaim space from old images you might have to remove them manually.
