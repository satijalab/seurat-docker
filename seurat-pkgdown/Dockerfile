# Dockerfile for building the pkgdown site
FROM satijalab/seurat:4.1.0

# Install system dependencies
RUN apt-get update
RUN apt-get install -y \
    parallel \
    pandoc \
    libbz2-dev \
    liblzma-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    curl

# Install later version of pandoc
RUN curl -L https://github.com/jgm/pandoc/releases/download/2.9.2.1/pandoc-2.9.2.1-linux-amd64.tar.gz --create-dirs -o software/pandoc-2.9.2.1-linux-amd64.tar.gz
RUN tar -zxvf software/pandoc-2.9.2.1-linux-amd64.tar.gz -C software/
RUN cp software/pandoc-2.9.2.1/bin/* /usr/bin/
RUN rm -rf software

# Set global R options
RUN echo "options(repos = c('https://cloud.r-project.org', 'https://bioconductor.org/packages/3.12/bioc'), timeout = 1000)" > $(R --no-echo --no-restore --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site

# Install R packages
RUN R --no-echo --no-restore --no-save -e "install.packages(c('rmarkdown', 'remotes', 'dplyr', 'testthat', 'roxygen2', 'htmltools', 'vembedr', 'htmlTable', 'pkgdown', 'yaml', 'knitr', 'kableExtra'))"
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('sjessa/ggmin')"
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('mojaveazure/seurat-disk')"
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('immunogenomics/presto')"

# Install Bioconductor dependencies
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('pcaMethods', 'scran', 'scater'))"
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('ggbio', 'biovizBase', 'AnnotationFilter', 'qvalue', 'EnsDb.Hsapiens.v86', 'BSgenome.Hsapiens.UCSC.hg38', 'chromVAR', 'TFBSTools', 'JASPAR2020', 'motifmatchr', 'Rsamtools'))"

# Install Signac
RUN R --no-echo --no-restore --no-save -e "install.packages('Signac')"

# Install python dependencies
RUN apt-get install -y python3-tables
RUN pip3 install scanpy

# Download vignette data
RUN mkdir data/
RUN wget https://www.dropbox.com/s/5b7czl109ibe8hn/all_vignette_files.tar.gz?dl=1 -P data --progress=bar:force:noscroll
RUN tar -zxvf data/all_vignette_files.tar.gz?dl=1 --strip-components=1 -C data/
RUN rm data/all_vignette_files.tar.gz?dl=1
RUN chmod -R a+rwx data/

# Get SeuratData
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('satijalab/seurat-data',  INSTALL_opts = '--no-test-load')"
RUN R --no-echo --no-restore --no-save -e "options(SeuratData.repo.use = 'satijalab04.nygenome.org'); SeuratData::InstallData(c('hcabm40k', 'ifnb', 'panc8', 'pbmcsca', 'stxBrain', 'ssHippo', 'pbmc3k', 'bmcite', 'thp1.eccite', 'pbmcMultiome'))"

# Tools to shrink size of vignettes
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y \
    pngquant \
    nodejs

RUN npm install html-minifier -g

# Install netlify CLI
RUN npm install --unsafe-perm=true -g netlify-cli

CMD [ "R" ]
