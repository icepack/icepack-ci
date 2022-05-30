#!/usr/bin/env bash
set -o nounset

python3 prepare-data.py
python3 -c "import icepack; icepack.datasets.fetch_mosaic_of_antarctica()"
cp -n $HOME/.cache/icepack/moa750_2009_hp1_v02.0.tif.gz ./
docker build --build-arg BASE_IMAGE=buildpack-deps:20.04 --tag icepack/firedrake-python3.8:$1 .
docker build --build-arg BASE_IMAGE=buildpack-deps:22.04 --tag icepack/firedrake-python3.10:$1 .
