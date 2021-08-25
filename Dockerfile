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

# Another hack because OpenMP and OpenBLAS are silly.
ENV OMP_NUM_THREADS=1

# Install some dependencies and create a Jupyter kernel for the virtual environment
RUN pip3 install ipykernel
RUN python3 -m ipykernel install --user --name=firedrake

# Copy some real data into the Docker image
COPY BedMachineAntarctica_2020-07-15_v02.nc .cache/icepack/BedMachineAntarctica_2020-07-15_v02.nc
COPY antarctic_ice_vel_phase_map_v01.nc .cache/icepack/antarctic_ice_vel_phase_map_v01.nc
COPY moa750_2009_hp1_v01.1.tif.gz .cache/icepack/moa750_2009_hp1_v01.1.tif.gz
COPY registry-nsidc.txt registry-nsidc.txt
RUN sudo chown -R sermilik .cache/icepack/
