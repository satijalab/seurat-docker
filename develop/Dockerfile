# Dockerfile for the development version of Seurat
FROM satijalab/seurat:4.0.2

# Install system dependencies
RUN apt-get install -y \
    libgit2-dev

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages('devtools')"
RUN R --no-echo --no-restore --no-save -e "install.packages('Matrix', lib = '/usr/local/lib/R/library/')"

CMD [ "R" ]
