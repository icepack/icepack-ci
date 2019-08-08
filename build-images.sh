docker build --tag icepack/firedrake-python3.5:0.1.0 --build-arg BASE_IMAGE=buildpack-deps:stretch --file Dockerfile .
docker build --tag icepack/firedrake-python3.7:0.1.0 --build-arg BASE_IMAGE=buildpack-deps:buster --file Dockerfile .
