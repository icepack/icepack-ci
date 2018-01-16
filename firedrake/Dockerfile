
FROM buildpack-deps:buster

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && apt-get -yq install \
    python3 \
    python3-pip \
    sudo

RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install && \
    python3 firedrake-install --verbose --disable-ssh

