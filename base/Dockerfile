FROM rocker/r-ver:4.1.1 AS rocker

FROM rocker/r2u:jammy AS setup-env

RUN apt-get update \
    && RUN apt-get install -y texlive \
    && RUN apt-get install -y texlive-fonts-extra

COPY --from=rocker /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh
RUN rm -rf rocker_scripts

COPY --from=rocker /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh
RUN rm -rf rocker_scripts


FROM setup-env AS install-bpcells

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'


FROM install-bpcells AS setup-workspace

RUN Rscript -e 'install.packages(c("argparse", "devtools"))'

COPY tools/install_deps.R /usr/local/bin/r-install-deps
COPY tools/install_pkg.R /usr/local/bin/r-install-pkg
COPY tools/cran_checks.R /usr/local/bin/r-cran-checks
COPY tools/test_pkg.R /usr/local/bin/r-test-pkg
