docker build --tag icepack/firedrake:stretch --build-arg BASE_IMAGE=buildpack-deps:stretch firedrake/
docker build --tag icepack/firedrake:buster --build-arg BASE_IMAGE=buildpack-deps:buster firedrake/
