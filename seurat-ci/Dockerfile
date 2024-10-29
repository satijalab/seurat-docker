FROM --platform=amd64 rocker/r2u:jammy

RUN apt-get update \
    && apt-get install -y libhdf5-dev \ 
    && install2.r --repos="https://bnprks.r-universe.dev" BPCells

RUN apt-get install -y \
    texlive-full \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    texlive-latex-extra \
    texinfo \
    qpdf \
    libharfbuzz-dev \
    libfribidi-dev \
    libgit2-dev

RUN apt-get install -y \
    pandoc \
    libv8-dev \
    tidy

ENV _R_CHECK_PKG_SIZES_="false"
ENV _R_CHECK_RD_XREFS_="false"
ENV _R_CHECK_CRAN_INCOMING_NOTE_GNU_MAKE_="false"
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_="true"
