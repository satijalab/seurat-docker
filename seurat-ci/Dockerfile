FROM --platform=amd64 rocker/r2u:noble

COPY install_rstudio.sh /usr/local/bin/install_rstudio
COPY setup_rstudio.sh /usr/local/bin/setup_rstudio
RUN install_rstudio

EXPOSE 8787
