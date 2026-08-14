# Dockerfile for the `satijalab/seurat-ci` image, intended for running CI 
# workflows for https://github.com/satijalab/seurat and its related projects 
# (e.g. https://github.com/satijalab/seurat-object).

FROM rocker/r-ver:4.6.1

ENV RSPM="https://packagemanager.posit.co/all/__linux__/noble/latest"
ENV PAK_PPM_URL="${RSPM}"
ENV CTAN_REPO="https://mirror.ctan.org/systems/texlive/tlnet"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"

# In addition to `rocker/r2u` images, the Rocker Project also provides a 
# set of images that comes with a set of shared setup scripts providing tools 
# from `pandoc` and `texlive` to `python` and `CUDA`, for more details, see
# https://github.com/rocker-org/rocker-versioned2?tab=readme-ov-file#rocker-scripts.
#
# Using multi-stage builds we can pull these scripts direclty from the 
# `rocker/r-ver` image and use them to install the things we need.
#
# TODO: consider vendorizing rocker_scripts/ directy into seurat-docker 
# and introducing a workflow to keeps its contents in sync with 
# https://github.com/rocker-org/rocker-versioned2/tree/master/scripts.
COPY --from=rocker/r-ver:latest /rocker_scripts/bin/ /rocker_scripts/bin/
COPY --from=rocker/r-ver:latest /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
COPY --from=rocker/r-ver:latest /rocker_scripts/install_texlive.sh /rocker_scripts/install_texlive.sh
RUN apt update \
    && apt install -y --no-install-recommends \ 
        # System dependencies not covered by the copied scripts.
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
    && tlmgr install amsfonts

# Install `BPCells` and `presto`, both only available from specific repositories.
# Since they are not available on CRAN or BioConductor, these
# packages need to be installed from source (r-universe).
# NOTE: BPCells installation is quite slow.
# NOTE: RcppArmadillo is pinned to 15.2.4-1; newer releases require
# C++14 while `presto` declares `CXX_STD = CXX11`.
RUN apt update \
    && apt install -y libhdf5-dev \ 
    && Rscript -e "\
options(repos = c(bnprks='https://bnprks.r-universe.dev', satijalab='https://satijalab.r-universe.dev')); \
remotes::install_version('RcppArmadillo', version='15.2.4-1', repos='https://cloud.r-project.org'); \
pak::pkg_install(c('BPCells','presto'))"

# Set environment variables to suppress NOTEs that are accepted by CRAN, see
# https://www.rdocumentation.org/packages/rcmdcheck/versions/1.4.0/topics/rcmdcheck
# for more details. 
ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"

# Remove scripts copied from `rocker/r-ver` and point /usr/local/bin/install2.r 
# back to the littler version. 
RUN ln -sf /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && rm -rf /rocker_scripts/
