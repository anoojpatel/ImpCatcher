FROM julia:1.8 as julia-base
FROM nvidia/cuda:11.0.3-base-ubuntu20.04 as base

# ubuntu 20.04 is derived from debian buster
COPY --from=julia-base /usr/local/julia /usr/local/julia

# since we are copying from julia-base, need to add to PATH
ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH
# cuda env vars to use cuda & julia https://cuda.juliagpu.org/stable/installation/overview/
ENV JULIA_CUDA_USE_BINARYBUILDER="false"
ENV JULIA_DEBUG CUDA
ENV CUDA_HOME /usr/local/cuda


RUN useradd --create-home --shell /bin/bash genie
RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app

# C compiler for PackageCompiler before non-root user is set
RUN apt-get update && apt-get install -y g++

RUN chown -R genie:genie /home/
USER genie



EXPOSE 8000
EXPOSE 80
ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV GENIE_ENV "dev"
ENV GENIE_HOST "0.0.0.0"
ENV PORT "8000"
ENV WSPORT "8000"

RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/anoojpatel/Chess.jl"); Pkg.activate("."); Pkg.add("Stipple"); Pkg.precompile()'

# Compile app
RUN julia --project make.jl

ENTRYPOINT julia --project --sysimage=sysimg.so -e 'using Pkg; Pkg.instantiate(); using Genie; Genie.loadapp(); up(async=false);;'
