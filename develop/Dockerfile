# Dockerfile for the development version of Seurat
FROM satijalab/seurat:4.1.0

# Install system dependencies
RUN apt-get install -y \
    libgit2-dev

# Install some other stuff for bridge integration
Run R --no-echo --no-restore --no-save -e "install.packages(c('fastDummies', 'RcppHNSW', 'Rspectra'))"

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"

CMD [ "R" ]
