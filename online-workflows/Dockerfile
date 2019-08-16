# Dockerfile for use with the CI of seurat-wrappers

FROM rstudio/r-base:3.6.1-xenial

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --slave --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site

# Install system dependencies
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
    git

# Install R packages

RUN R --slave --no-restore --no-save -e "install.packages(c('rmarkdown', 'devtools', 'dplyr', \
    'ape', 'cluster', 'cowplot', 'fitdistrplus', 'future', 'future.apply', 'ggplot2', 'ggrepel', \
    'ggridges', 'graphics', 'grDevices', 'grid', 'ica', 'igraph', 'irlba', 'KernSmooth', 'leiden', \
    'lmtest', 'MASS', 'Matrix', 'metap','pbapply', 'plotly', 'png', 'RANN', 'RColorBrewer', 'Rcpp', \
    'RcppAnnoy', 'reticulate', 'rlang', 'ROCR', 'rsvd', 'Rtsne', 'scales', 'sctransform', 'SDMTools', \
    'stats', 'tools', 'tsne', 'utils', 'uwot', 'testthat', 'hdf5r', 'roxygen2', 'Rcpp', 'RcppEigen'))"

# Install LoomR

RUN  R --slave --no-restore --no-save -e "devtools::install_github('mojaveazure/loomR', ref = 'develop')"

# Install Bioconductor dependencies 

RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran', 'S4Vectors', \
'SummarizedExperiment', 'SingleCellExperiment', 'MAST', 'DESeq2', 'GenomicRanges', 'GenomeInfoDb', \
'IRanges', 'rtracklayer', 'monocle', 'Biobase', 'VGAM', 'scater'))"

# Install python dependencies
RUN pip3 install scanpy

# Install FIt-sne
RUN apt-get install -y libfftw3-dev
RUN git clone https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

CMD [ "R" ]
