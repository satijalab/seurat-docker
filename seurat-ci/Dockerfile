FROM --platform=amd64 rocker/r2u:noble

RUN mkdir /home/root/

RUN sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

COPY rstudio_scripts/install.sh /rstudio_scripts/install.sh
COPY rstudio_scripts/oncreate.sh /rstudio_scripts/oncreate.sh
RUN /rstudio_scripts/install.sh

EXPOSE 8787

CMD ["rserver", "--server-daemonize=0"]
