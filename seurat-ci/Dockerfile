# Dockerfile for the `satijalab/seurat-ci` image, intended for running CI 
# workflows for https://github.com/satijalab/seurat and its related projects 
# (e.g. https://github.com/satijalab/seurat-object).

# rocker/r-ver provides reproducible builds to fixed versions of R
# See https://rocker-project.org/images/versioned/r-ver.html
FROM rocker/r-ver:4.6.1

# Use Posit's RSPM (RStudio Package Manager) for installing packages.
ENV RSPM="https://packagemanager.posit.co/all/__linux__/noble/latest"
ENV PAK_PPM_URL="${RSPM}"
# Set a CTAN mirror and add `texlive` to the PATH.
ENV CTAN_REPO="https://mirror.ctan.org/systems/texlive/tlnet"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        texinfo \
        tidy \
        libhdf5-dev \
    # Scripts from littler are available under `/rocker_scripts/bin`.
    && ln -sf /rocker_scripts/bin/install2.r /usr/local/bin/install2.r \
    && ln -sf /rocker_scripts/bin/installDeps.r /usr/local/bin/installDeps.r \
    && /rocker_scripts/install_pandoc.sh \
    && /rocker_scripts/install_texlive.sh \
    && export PATH="/usr/local/texlive/bin/linux:$PATH" \
    # Install amsfonts separately for PDF manual generation, which is checked by CRAN.
    && tlmgr install amsfonts \
    # Set default package repositories (RSPM and r-universe repos)
    && echo "options(repos = c(satijalab = 'https://satijalab.r-universe.dev', bnprks = 'https://bnprks.r-universe.dev', CRAN = Sys.getenv('RSPM')))" >> "$(R RHOME)/etc/Rprofile.site" \
    && rm -rf /var/lib/apt/lists/*

# Install R packages with littler scripts
# Install `BPCells` and `presto`, both only available from specific r-universe repositories.
# NOTE: BPCells installation is quite slow.
RUN install2.r --error --skipinstalled --ncpus -1 \
      -r https://bnprks.r-universe.dev \
      -r https://satijalab.r-universe.dev \
    -r ${RSPM} \
    BiocManager devtools pak plotly remotes V8 BPCells presto

# Set environment variables to suppress NOTEs that are accepted by CRAN, see
# https://www.rdocumentation.org/packages/rcmdcheck/versions/1.4.0/topics/rcmdcheck
# for more details. 
ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"