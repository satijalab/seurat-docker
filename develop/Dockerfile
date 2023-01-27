# Dockerfile for the development version of Seurat
FROM satijalab/seurat:4.3.0

# Install system dependencies
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y \
    libgit2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Install some other stuff for bridge integration
RUN R --no-echo --no-restore --no-save -e "install.packages(c('fastDummies', 'RcppHNSW', 'RSpectra', 'lifecycle', 'generics'))"

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"

CMD [ "R" ]
