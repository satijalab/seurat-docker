# Dockerfile for the latest version of Seurat (v3.1.4)
FROM rstudio/r-base:3.6.3-bionic
ENV DEBIAN_FRONTEND noninteractive

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
    libfftw3-dev \
    pandoc 

# Install UMAP
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor dependencies
RUN R --slave --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --slave --no-restore --no-save -e "BiocManager::install('multtest')"
RUN R --slave --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran', 'S4Vectors', \
'SummarizedExperiment', 'SingleCellExperiment', 'MAST', 'DESeq2', 'GenomicRanges', 'GenomeInfoDb', \
'IRanges', 'rtracklayer', 'monocle', 'Biobase', 'VGAM', 'scater'))"

# Install hdf5r
RUN R --slave --no-restore --no-save -e "install.packages('hdf5r')"

# Install new develop R dependencies
RUN R --slave --no-restore --no-save -e "install.packages(c('patchwork', 'testthat', 'devtools', 'tinytex'))"
RUN echo "if (requireNamespace('tinytex', quietly = TRUE)) { \n"\
    "sep <- .Platform[['path.sep']] \n"\
    "tex.bin <- tinytex::tinytex_root() \n"\
    "tex.bin <- list.dirs(path = file.path(tex.bin, 'bin')) \n"\
    "tex.bin <- paste(tex.bin, collapse = sep) \n"\
    "Sys.setenv(PATH = paste(tex.bin, Sys.getenv('PATH'), sep = sep)) \n"\
    "}"\ 
    >> $(R --slave --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
RUN R --slave --no-restore --no-save -e "devtools::install_version('SDMTools', version = '1.1-221.2', repos = 'http://cran.us.r-project.org')"

# Install loomR
RUN R --slave --no-restore --no-save -e "devtools::install_github('mojaveazure/loomR', ref = 'develop')"

# Install Seurat
RUN R --slave --no-restore --no-save -e "install.packages('Seurat')"

CMD [ "R" ]
