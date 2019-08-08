ARG BASE_IMAGE=buildpack-deps:stretch
FROM $BASE_IMAGE

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && apt-get -yq install \
    binutils \
    bison \
    build-essential \
    cmake \
    flex \
    gfortran \
    libgdal20 \
    libgdal-dev \
    libnetcdf-dev \
    libopenmpi-dev \
    openmpi-bin \
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

# Install firedrake.
RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install && \
    PETSC_CONFIGURE_OPTIONS="--download-suitesparse" python3 firedrake-install --verbose --disable-ssh --minimal-petsc --no-package-manager

# Hack to activate the firedrake virtual environment.
ENV PATH=/home/user/firedrake/bin:$PATH

RUN pip3 install \
    rasterio \
    scipy
