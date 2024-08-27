FROM rocker/r2u:latest

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'
