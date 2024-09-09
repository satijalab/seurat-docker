FROM rocker/r-ver:4.1.1 AS rocker

FROM rocker/r2u:jammy

RUN apt-get update \
    && apt-get install -y texlive \
    && apt-get install -y texlive-fonts-extra

COPY --from=rocker /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh
RUN rm -rf rocker_scripts

COPY --from=rocker /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh
RUN rm -rf rocker_scripts

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'

RUN Rscript -e 'install.packages(c("devtools"))'
