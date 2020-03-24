# Dockerfile for use with the CI of seurat-wrappers
FROM satijalab/seurat:3.1.4

# Install system dependencies
RUN apt-get update
RUN apt-get install -y \
    parallel

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --slave --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site

# Install R packages

RUN R --slave --no-restore --no-save -e "install.packages(c('rmarkdown', 'devtools', 'dplyr', 'testthat', 'roxygen2'))"
RUN R --slave --no-restore --no-save -e "devtools::install_github('sjessa/ggmin')"

# Install LoomR

RUN  R --slave --no-restore --no-save -e "devtools::install_github('mojaveazure/loomR', ref = 'develop')"

# Install Bioconductor dependencies 

RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran', 'scater'))"

# Install python dependencies
RUN apt-get install -y python3-tables
RUN pip3 install scanpy

# Download vignette data
RUN curl -L https://www.dropbox.com/s/1wuvexjk9urtr01/all_vignette_files.tar.gz?dl=0 --create-dirs -o data/all_vignette_files.tar.gz
RUN tar -zxvf data/all_vignette_files.tar.gz --strip-components=1 -C data/
RUN rm data/all_vignette_files.tar.gz
RUN chmod -R a+rwx data/

# Get SeuratData
RUN R --slave --no-restore --no-save -e "remotes::install_github('satijalab/seurat-data',  INSTALL_opts = '--no-test-load')"
RUN R --slave --no-restore --no-save -e "options(SeuratData.repo.use = 'satijalab04.nygenome.org'); SeuratData::InstallData(c('hcabm40k', 'ifnb', 'panc8', 'pbmcsca'))"

CMD [ "R" ]
