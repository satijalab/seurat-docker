# Dockerfile for the `satijalab/seurat-ci` image, intended for running CI 
# workflows for https://github.com/satijalab/seurat and its related projects 
# (e.g. https://github.com/satijalab/seurat-object).

FROM rocker/r-ver:4.6.1

ENV RSPM="https://packagemanager.posit.co/all/__linux__/noble/latest"
ENV PAK_PPM_URL="${RSPM}"
ENV CTAN_REPO="https://mirror.ctan.org/systems/texlive/tlnet"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        texinfo \
        tidy \
        # R packages (brought to you by r2u).
        r-cran-devtools \
        r-cran-plotly \
        r-cran-v8 \
    # The `install2.r` script comes from the `littler` package and is included 
    # under `/usr/local/bin/` by the base image. The version found under 
    # `/rocker_scripts/bin/install2.r` differs from the `littler` version in 
    # two ways:
    #   1. It does not provide a `--type` flag
    #   2. It exposes an additional `--skipmissing` flag
    # Neither flag is actually used in the following scripts but it's probably 
    # best to make sure that we're using the intended version just to be safe.
    && ln -sf /rocker_scripts/bin/install2.r /usr/local/bin/install2.r \
    && /rocker_scripts/install_pandoc.sh \
    && /rocker_scripts/install_texlive.sh \
    && export PATH="/usr/local/texlive/bin/linux:$PATH" \
    # Install amsfonts separately for PDF manual generation, which is checked by CRAN.
    && tlmgr install amsfonts \
    # Set a single binary-capable repo for CRAN + Bioconductor
    && echo "options(repos = c(CRAN = Sys.getenv('RSPM')))" >> "$(R RHOME)/etc/Rprofile.site" \
    && rm -rf /var/lib/apt/lists/*

# Install R packages with littler scripts
RUN install2.r --error --skipinstalled --ncpus -1 \
    -r ${RSPM} \
    BiocManager devtools pak plotly remotes V8

# Install `BPCells` and `presto`, both only available from specific r-universe repositories.
# NOTE: BPCells installation is quite slow.
RUN install2.r --error --skipinstalled --ncpus -1 \
      -r https://bnprks.r-universe.dev \
      -r https://satijalab.r-universe.dev \
    -r ${RSPM} \
      BPCells presto

# Set environment variables to suppress NOTEs that are accepted by CRAN, see
# https://www.rdocumentation.org/packages/rcmdcheck/versions/1.4.0/topics/rcmdcheck
# for more details. 
ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"