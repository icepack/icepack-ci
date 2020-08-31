ARG BASE_IMAGE=buildpack-deps:20.04
FROM $BASE_IMAGE

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -yq install \
    binutils \
    bison \
    build-essential \
    cmake \
    flex \
    gfortran \
    libgdal-dev \
    libglu1-mesa \
    libnetcdf-dev \
    libxcursor1 \
    libxinerama1 \
    python \
    python3 \
    python3-pip \
    python3-tk \
    python3-venv \
    sudo

# Run as a non-root user with sudo privileges.
RUN echo "Defaults lecture = never" >> /etc/sudoers.d/privacy
RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd --create-home --shell /bin/bash --password $(openssl passwd -1 password) sermilik
RUN usermod --append --groups sudo sermilik

USER sermilik
WORKDIR /home/sermilik

# GDAL installs its headers in a location that it can't find later.
ENV C_INCLUDE_PATH=/usr/include/gdal \
    CPLUS_INCLUDE_PATH=/usr/include/gdal

# Fetch and install gmsh
RUN curl -O http://gmsh.info/bin/Linux/gmsh-4.5.6-Linux64.tgz && \
    tar xvf gmsh-4.5.6-Linux64.tgz && \
    sudo cp gmsh-4.5.6-Linux64/bin/gmsh /usr/bin

# Put all the firedrake installation options, including commit hashes for all
# dependencies, into a file.
COPY package-branches ./package-branches
RUN echo $(sed 's/^/--package-branch /' package-branches | tr '\n' ' ') \
    > package-branch-options

# Install firedrake.
RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/$(grep "firedrake" ./package-branches | cut -d' ' -f2)/scripts/firedrake-install
RUN python3 firedrake-install \
    --verbose \
    --disable-ssh \
    --minimal-petsc \
    --no-package-manager \
    --remove-build-files \
    $(cat package-branch-options)

# Hack to activate the firedrake virtual environment.
ENV PATH=/home/sermilik/firedrake/bin:$PATH

RUN pip3 install scipy
RUN pip3 install rasterio==1.0.28
