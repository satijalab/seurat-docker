# Dockerfile for Seurat 5.x (CRAN or development version)

#### USAGE --
# docker build -t image-name --build-arg SEURAT_REF=ref .
# SEURAT_REF can be either "cran" (latest stable release) or "dev" (development version)

# ex. docker build -t seurat --build-arg SEURAT_REF="cran" --progress=plain .
####

# Build stage
FROM rocker/tidyverse:4.4.2 AS build

ARG SEURAT_REF=cran

RUN if [ "${SEURAT_REF}" != "dev" ] && [ "${SEURAT_REF}" != "cran" ]; then \
        echo -e "\033[31mError: SEURAT_REF must be either 'dev' or 'cran', got: ${SEURAT_REF}\033[0m" && exit 1; \
    fi

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV R_PKG_INSTALL_ARGS="--no-html"

ENV RETICULATE_MINICONDA_ENABLED=FALSE

# Install Seurat's system dependencies
RUN apt-get update && \
    echo -e "\033[1;32mInstalling system dependencies\033[0m" && \
    apt-get install -y --no-install-recommends \
        cmake \
        git \
        libboost-all-dev \
        libcurl4-openssl-dev \
        libfftw3-dev \
        libgdal-dev \
        libgeos-dev \
        libgsl-dev \
        libhdf5-dev \
        libpng-dev \
        libproj-dev \
        libssl-dev \
        libudunits2-dev \
        libxml2-dev \
        llvm \
        openjdk-17-jdk \
        patch \
        pkg-config \
        python3-dev \
        python3-pip \
        python3.12-venv \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install UMAP via python venv
RUN echo -e "\033[1;32mInstalling python dependencies via venv\033[0m" && \
    python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir numpy umap-learn llvmlite

ENV PATH="/opt/venv/bin:${PATH}"

RUN Rscript -e "install.packages('pak', repos='https://r-lib.github.io/p/pak/stable/')"

# Set library path to avoid conflicts
RUN Rscript -e "dir.create('/usr/local/lib/R/custom-lib', recursive = TRUE); .libPaths('/usr/local/lib/R/custom-lib')"

# Install imports via pak
RUN echo -e "\033[1;32mInstalling required dependencies via pak\033[0m" && \
    Rscript -e "\
options(repos = c(cran = 'https://cloud.r-project.org', \
                  bioconductor = 'https://bioconductor.org/packages/bioc')); \
pak::pkg_install(c( \
    'cluster','cowplot','fastDummies','fitdistrplus','future','future.apply', \
    'generics','ggplot2','ggrepel','ggridges','graphics','grDevices','grid', \
    'httr','ica','igraph','irlba','jsonlite','KernSmooth','leidenbase', \
    'lifecycle','lmtest','MASS','Matrix','matrixStats','miniUI','patchwork', \
    'pbapply','plotly','png','progressr','RANN','RColorBrewer','Rcpp', \
    'RcppAnnoy','RcppHNSW','reticulate','rlang','ROCR','RSpectra','Rtsne', \
    'scales','scattermore','sctransform','shiny','spatstat.explore', \
    'spatstat.geom','stats','tibble','tools','utils','uwot'), upgrade = TRUE)" && \
    rm -rf /root/.cache/R /tmp/*

RUN echo -e "\033[1;32mInstalling other dependencies via pak\033[0m" && \
    Rscript -e "\
options(repos = c(cran = 'https://cloud.r-project.org', \
                  bioconductor = 'https://bioconductor.org/packages/bioc')); \
pak::pkg_install(c( \
    'ape','arrow','base64enc','Biobase','BiocGenerics','data.table','DESeq2', \
    'DelayedArray','enrichR','GenomicRanges','GenomeInfoDb','glmGamPoi', \
    'ggrastr','harmony','hdf5r','IRanges','limma','magrittr','MAST','metap', \
    'mixtools','monocle','rsvd','R.utils','Rfast2','rtracklayer','S4Vectors', \
    'sf','sp','SingleCellExperiment','SummarizedExperiment','testthat','VGAM'), \
upgrade = TRUE)" && \
    rm -rf /root/.cache/R /tmp/*

RUN Rscript -e "\
options(repos = c(bnprks='https://bnprks.r-universe.dev', satijalab='https://satijalab.r-universe.dev')); \
pak::pkg_install(c('BPCells','presto'))" && \
    rm -rf /root/.cache/R /tmp/*

# Install Seurat
RUN if [ "${SEURAT_REF}" = "cran" ]; then \
    # Stable, mirrors latest CRAN release (GitHub branch "cran")
    echo "\033[1;32mInstalling latest stable Seurat version\033[0m" && \
    Rscript -e "pak::pkg_install(c('satijalab/seurat-object@cran','satijalab/seurat@cran'))"; \
elif [ "${SEURAT_REF}" = "dev" ]; then \
    # Development (GitHub branch "main")
    echo "\033[1;32mInstalling development version of Seurat\033[0m" && \
    Rscript -e "pak::pkg_install(c('satijalab/seurat-object@main','satijalab/seurat@main'))"; \
fi && \
rm -rf /root/.cache/R /tmp/*

# Runtime stage
FROM rocker/r-ver:4.4.2 AS runtime

ENV PATH="/opt/venv/bin:${PATH}"

# Copy only what is needed at runtime
COPY --from=build /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=build /opt/venv /opt/venv

CMD ["R"]
