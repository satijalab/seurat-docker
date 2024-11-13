FROM --platform=amd64 rocker/r2u:noble

ENV USERNAME="docker"

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

COPY rstudio_scripts/install.sh /rstudio_scripts/install_rstudio.sh
COPY rstudio_scripts/oncreate.sh /rstudio_scripts/oncreate.sh

EXPOSE 8787
