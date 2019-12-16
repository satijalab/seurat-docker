# Dockerfile for the latest version of Seurat (v3.1.2)
FROM rstudio/r-base:3.6.1-xenial

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
    wget \
    git \
    libfftw3-dev

# Install UMAP
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor dependencies
RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install('multtest')"

# Install Seurat
RUN R --slave --no-restore --no-save -e "install.packages('Seurat')"

CMD [ "R" ]
