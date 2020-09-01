# Dockerfile for the development version of Seurat
FROM satijalab/seurat:3.2.0

# Install new develop R dependencies
RUN R --slave --no-restore --no-save -e "install.packages('devtools')"
RUN R --slave --no-restore --no-save -e "install.packages(c('ggplotify','enrichR', 'mixtools'))"

# Install loomR
RUN R --slave --no-restore --no-save -e "devtools::install_github('mojaveazure/loomR', ref = 'develop')"

# Install rcmdcheck
RUN R --slave --no-restore --no-save -e "install.packages('rcmdcheck')"

CMD [ "R" ]
