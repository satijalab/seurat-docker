# Dockerfile for Seurat (CRAN or development version)

#### USAGE --
# docker build -t image-name --build-arg SEURAT_REF=ref .
# SEURAT_REF can be either "cran" (latest stable release) or "dev" (development version)

# ex. docker build -t seurat --build-arg SEURAT_REF="cran" --progress=plain .
####

FROM rocker/tidyverse:4.6.1

ARG SEURAT_REF=cran

RUN if [ "${SEURAT_REF}" != "dev" ] && [ "${SEURAT_REF}" != "cran" ]; then \
        echo -e "\033[31mError: SEURAT_REF must be either 'dev' or 'cran', got: ${SEURAT_REF}\033[0m" && exit 1; \
    fi

# Set global R options
RUN echo "options(repos = c(CRAN = 'https://cloud.r-project.org', satijalab = 'https://satijalab.r-universe.dev', bnprks = 'https://bnprks.r-universe.dev'))" >> "$(R RHOME)/etc/Rprofile.site"
ENV R_PKG_INSTALL_ARGS="--no-html"

# pak will automatically install system libraries from its req database
# so here we only install minimal system dependencies that are not handled by pak
ENV PKG_SYSREQS=true
RUN apt-get update && \
    apt-get install -y --no-install-recommends git make patch && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages('pak', repos='https://r-lib.github.io/p/pak/stable/', type='source'); stopifnot(pak::sysreqs_is_supported())"

# Set library path to avoid conflicts
RUN mkdir -p /usr/local/lib/R/custom-lib
ENV R_LIBS_USER=/usr/local/lib/R/custom-lib

# Install Depends, Imports, Suggests and LinkingTo + development/documentation tools
# graphics, grDevices, grid, stats, tools, and utils are base R packages so do not need to be installed separately
RUN echo "Installing required dependencies via pak" && \
    Rscript -e "\
pak::pkg_install(c('cluster','cowplot','fastDummies','fitdistrplus','future','future.apply', 'generics','ggplot2','ggrepel','ggridges','httr','ica', \
    'igraph','irlba','jsonlite','KernSmooth','leidenbase','lifecycle','lmtest','MASS', 'Matrix','matrixStats','miniUI','parallelly','patchwork','pbapply', \
    'plotly','pls','png','progressr', 'RANN','RColorBrewer','Rcpp','RcppAnnoy','RcppEigen','RcppHNSW','RcppProgress','RcppThread','reticulate','rlang', \
    'ROCR','RSpectra','Rtsne','scales','scattermore','sctransform','shiny','spatstat.explore','spatstat.geom','tibble','uwot','ape','arrow','base64enc', \
    'Biobase','BiocGenerics','blosc','circlize','ComplexHeatmap','data.table','DESeq2','DelayedArray','theislab/destiny@60d1159','enrichR','GenomicRanges', \
    'GenomeInfoDb','glmGamPoi','ggrastr','harmony','hdf5r','IRanges','limma','magrittr','MAST', 'metap','mixtools','monocle','RBioFormats','rsvd','R.utils', \
    'Rfast2','rtracklayer','S4Vectors','sf','sp','spls','SingleCellExperiment','SummarizedExperiment','testthat','VGAM','devtools','pkgdown'), ask = FALSE)" && \
    rm -rf /root/.cache/R /tmp/* /var/lib/apt/lists/*

RUN Rscript -e "\
options(repos=c(bnprks='https://bnprks.r-universe.dev', \
        satijalab='https://satijalab.r-universe.dev', \
        cran='https://cloud.r-project.org')); \
pak::pkg_install(c('BPCells', 'presto'), ask = FALSE)" && \
    rm -rf /root/.cache/R /tmp/* /var/lib/apt/lists/*

# Install SeuratData
RUN Rscript -e "pak::pkg_install('satijalab/seurat-data', ask = FALSE)" && \
    rm -rf /root/.cache/R /tmp/* /var/lib/apt/lists/*

# Install Seurat
RUN if [ "${SEURAT_REF}" = "cran" ]; then \
    # Stable, mirrors latest CRAN release (GitHub branch "cran")
    echo "\033[1;32mInstalling latest stable Seurat version\033[0m" && \
    Rscript -e "pak::pkg_install(c('satijalab/seurat-object@cran','satijalab/seurat@cran'), ask = FALSE)"; \
elif [ "${SEURAT_REF}" = "dev" ]; then \
    # Development (GitHub branch "main")
    echo "\033[1;32mInstalling development version of Seurat\033[0m" && \
    Rscript -e "pak::pkg_install(c('satijalab/seurat-object@main','satijalab/seurat@main'), ask = FALSE)"; \
fi && \
rm -rf /root/.cache/R /tmp/* /var/lib/apt/lists/*

# Also cover system requirements of preinstalled or cached R packages
RUN Rscript -e "pak::sysreqs_fix_installed(); \
    reqs <- pak::sysreqs_check_installed(); print(reqs); \
    stopifnot(all(reqs[['installed']])); \
    library(Seurat); print(packageVersion('Seurat'))" && \
    rm -rf /root/.cache/R /tmp/* /var/lib/apt/lists/*

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
CMD ["R"]
