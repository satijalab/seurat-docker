# Dockerfile for the development version of Seurat
FROM satijalab/seurat:4.0.1

# Install system dependencies
RUN apt-get install -y \
    libgit2-dev

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"

CMD [ "R" ]
