FROM rocker/r2u:latest AS base-setup

RUN apt-get update
RUN apt-get install -y pandoc
RUN apt-get install -y texlive
RUN apt-get install -y texlive-fonts-extra


FROM base-setup AS install-bpcells

RUN apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'


FROM install-bpcells AS setup-env

ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"

RUN Rscript -e 'install.packages("argparse")'
RUN Rscript -e 'install.packages("devtools")'

COPY scripts/install_deps.R /usr/local/bin/install_deps
COPY scripts/install_pkg.R /usr/local/bin/install_pkg
COPY scripts/run_checks.R /usr/local/bin/run_checks
COPY scripts/run_tests.R /usr/local/bin/run_tests

WORKDIR /github/workspace

CMD install_deps --all && run_checks
