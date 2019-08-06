# Dockerfile for the latest version of Seurat (v3.0.2)
FROM rstudio/r-base:3.5-xenial

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --slave --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site

# Install Seurat's system dependencies
RUN apt-get update
RUN apt-get install -y \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpng-dev \
    libboost-all-dev \
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget

# Install UMAP
RUN pip3 install umap-learn

# Install Seurat
RUN R --slave --no-restore --no-save -e "install.packages('Seurat')"

CMD [ "R" ]
