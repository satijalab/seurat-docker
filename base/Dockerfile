FROM rocker/r-ver:4.1.1 AS rocker

FROM rocker/r2u:jammy AS install-pandoc

COPY --from=rocker /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh
RUN rm -rf rocker_scripts/


FROM install-pandoc AS install-quarto

COPY --from=rocker /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh
RUN rm -rf rocker_scripts/


FROM install-quarto AS install-latex

ENV CTAN_REPO="https://mirror.ctan.org/systems/texlive/tlnet"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"

COPY --from=rocker /rocker_scripts/install_verse.sh /rocker_scripts/install_verse.sh
COPY --from=rocker /rocker_scripts/install_texlive.sh /rocker_scripts/install_texlive.sh
RUN /rocker_scripts/install_verse.sh
RUN rm -rf rocker_scripts/


FROM install-latex AS install-bpcells

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'


FROM install-bpcells AS install-devtools

RUN Rscript -e 'install.packages(c("devtools"))'
