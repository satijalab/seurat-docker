# Dockerfile for use with the CI of seurat-wrappers
FROM satijalab/seurat:latest

# Install system dependencies
RUN apt-get update
RUN apt-get install -y \
	git

# Install R packages

RUN R --slave --no-restore --no-save -e "install.packages(c('rmarkdown', 'devtools', 'dplyr'))"

# Install Bioconductor dependencies 

RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran'))"

CMD [ "R" ]
