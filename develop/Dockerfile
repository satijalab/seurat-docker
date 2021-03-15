# Dockerfile for the development version of Seurat
FROM satijalab/seurat:4.0.0

# Install system dependencies
RUN apt-get install -y \
    libgit2-dev

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"
RUN R --no-echo --no-restore --no-save -e "install.packages(c('spatstat.core', 'spatstat.geom'))"

CMD [ "R" ]
