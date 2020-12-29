# Dockerfile for the development version of Seurat
FROM satijalab/seurat:3.2.3

# Install system dependencies
RUN apt-get install -y \
    libgit2-dev

# Install new develop R dependencies
RUN R --no-echo --no-restore --no-save -e "install.packages(c('enrichR', 'mixtools', 'remotes', 'devtools'))"

# Install loomR
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('mojaveazure/loomR', ref = 'develop')"

# Install rcmdcheck
RUN R --no-echo --no-restore --no-save -e "install.packages('rcmdcheck')"

CMD [ "R" ]
