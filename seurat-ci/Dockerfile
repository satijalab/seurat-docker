FROM --platform=amd64 rocker/r2u:jammy

RUN apt-get update \
    && apt-get install -y libhdf5-dev \ 
    && install2.r --repos="https://bnprks.r-universe.dev" BPCells

RUN apt-get update \
    && apt-get install -y \
        qpdf \
        libharfbuzz-dev \
        libfribidi-dev \
        libgit2-dev \
        pandoc \
        libv8-dev \
        tidy

ENV DEFAULT_USER="docker"

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $DEFAULT_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEFAULT_USER \
    && chmod 0440 /etc/sudoers.d/$DEFAULT_USER \
    && sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

USER ${DEFAULT_USER}

ENV HOME="/home/${DEFAULT_USER}"
ENV PATH="${HOME}/bin:${PATH}"

RUN Rscript -e 'install.packages("tinytex"); tinytex::install_tinytex(); tinytex::tlmgr_install(c("makeindex", "inconsolata"))'

ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"
