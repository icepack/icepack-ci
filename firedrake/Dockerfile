
FROM buildpack-deps:buster

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && apt-get -yq install \
    libgdal20 \
    libgdal-dev \
    libnetcdf13 \
    libnetcdf-dev \
    python3 \
    python3-pip \
    sudo

ENV C_INCLUDE_PATH=/usr/include/gdal \
    CPLUS_INCLUDE_PATH=/usr/include/gdal

RUN curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install && \
    PETSC_CONFIGURE_OPTIONS="--download-suitesparse" python3 firedrake-install --verbose --disable-ssh --minimal-petsc

RUN . firedrake/bin/activate && \
    pip3 install \
    rasterio \
    scipy
