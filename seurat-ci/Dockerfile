FROM rocker/r2u:latest AS install-bpcells

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'


FROM install-bpcells AS setup-env

ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"

COPY scripts/install_required_deps.R /usr/local/bin/install_required_deps
COPY scripts/install_optional_deps.R /usr/local/bin/install_optional_deps
COPY scripts/install_pkg.R /usr/local/bin/rscripts/install_pkg
COPY scripts/run_checks.R /usr/local/bin/rscripts/run_checks
