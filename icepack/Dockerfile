
FROM icepack/firedrake:latest

MAINTAINER shapero.daniel@gmail.com

RUN apt-get update && apt-get -yq install \
    libgdal20 \
    libgdal-dev \
    libnetcdf13 \
    libnetcdf-dev

ENV C_INCLUDE_PATH=/usr/include/gdal \
    CPLUS_INCLUDE_PATH=/usr/include/gdal
