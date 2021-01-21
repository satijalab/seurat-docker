# Dockerfile for use with the CI to build the Seurat pkgdown site

FROM satijalab/online-workflows:4.0.0-beta

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site

# Install system dependencies
RUN apt-get update
RUN apt-get install -y \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \ 
    libjpeg-dev \
    curl

# Install R packages

RUN R --no-echo --no-restore --no-save -e "install.packages(c('pkgdown', 'htmlTable', 'yaml', 'knitr', 'kableExtra'))"
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('satijalab/seurat', ref = '9969ce5d11a24754531cde2030926ebf029866da')"
RUN R --no-echo --no-restore --no-save -e "install.packages('Signac')"

# Install later version of pandoc

RUN curl -L https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-linux-amd64.tar.gz --create-dirs -o software/pandoc-2.9.2.1-linux-amd64.tar.gz
RUN tar -zxvf software/pandoc-2.9.2.1-linux-amd64.tar.gz -C software/
RUN cp software/pandoc-2.9.2.1/bin/* /usr/bin/
RUN rm -rf software

CMD [ "R" ]
