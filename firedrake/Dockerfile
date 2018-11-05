
FROM buildpack-deps:buster

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && apt-get -yq install \
    cmake \
    gfortran \
    libgdal20 \
    libgdal-dev \
    libnetcdf13 \
    libnetcdf-dev \
    libopenmpi-dev \
    openmpi-bin \
    python3 \
    python3-pip \
    python3-tk \
    python3-venv \
    sudo

ENV C_INCLUDE_PATH=/usr/include/gdal \
    CPLUS_INCLUDE_PATH=/usr/include/gdal

RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install && \
    PETSC_CONFIGURE_OPTIONS="--download-suitesparse" python3 firedrake-install --verbose --disable-ssh --minimal-petsc

ENV PATH=/firedrake/bin:$PATH

RUN pip3 install \
    rasterio \
    scipy
