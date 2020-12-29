# Dockerfile for use with the CI of seurat-wrappers
FROM satijalab/seurat:latest

# Install system dependencies
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update
RUN apt-get install -y \
	git \
    libcairo2-dev

# Install R packages

RUN R --slave --no-restore --no-save -e "install.packages(c('rmarkdown', 'devtools', 'dplyr'))"
RUN R --slave --no-restore --no-save -e "remotes::install_github('kstreet13/scry@r3')"

# Install Bioconductor dependencies 

RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran', 'batchelor'))"

# Install SeuratWrappers
RUN  R --slave --no-restore --no-save -e "devtools::install_github('satijalab/seurat-wrappers', dependencies = TRUE)"

CMD [ "R" ]
