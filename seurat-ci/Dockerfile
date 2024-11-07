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
        tidy \
    && apt-get install -y \
        r-cran-tinytex \
    && Rscript -e 'tinytex::install_tinytex(add_path = FALSE)' \
    && Rscript -e 'tinytex::tlmgr(c("option", "sys_bin", "/usr/local/bin"))' \
    && Rscript -e 'tinytex::tlmgr_path()' \
    && Rscript -e 'tinytex::tlmgr_install("makeindex")'

ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"
