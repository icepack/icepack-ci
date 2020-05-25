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
    libmpich-dev \
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
RUN useradd --create-home --shell /bin/bash --password $(openssl passwd -1 password) user
RUN usermod --append --groups sudo user

USER user
WORKDIR /home/user

# GDAL installs its headers in a location that it can't find later.
ENV C_INCLUDE_PATH=/usr/include/gdal \
    CPLUS_INCLUDE_PATH=/usr/include/gdal

# Fetch and install gmsh
RUN curl -O http://gmsh.info/bin/Linux/gmsh-4.5.6-Linux64.tgz && \
    tar xvf gmsh-4.5.6-Linux64.tgz && \
    sudo cp gmsh-4.5.6-Linux64/bin/gmsh /usr/bin

# Put all the firedrake installation options, including commit hashes for all
# dependencies, into a file.
ADD package-branches /home/user/package-branches
RUN echo '--verbose --disable-ssh --minimal-petsc --no-package-manager' \
    $(sed 's/^/--package-branch /' package-branches | tr '\n' ' ') \
    > install-options

# Install firedrake.
RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/$(grep "firedrake" /home/user/package-branches | cut -d' ' -f2)/scripts/firedrake-install
ENV PETSC_CONFIGURE_OPTIONS="--download-suitesparse"
RUN python3 firedrake-install $(cat install-options)

# Hack to activate the firedrake virtual environment.
ENV PATH=/home/user/firedrake/bin:$PATH

RUN pip3 install scipy
RUN pip3 install rasterio==1.0.28
