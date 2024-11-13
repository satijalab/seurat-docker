FROM --platform=amd64 rocker/r2u:noble

ENV USERNAME="docker"

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

RUN mkdir -p /home/$USERNAME/.config/rstudio \
    && cat <<EOF /home/$USERNAME/.config/rstudio/rstudio-prefs.json
{
    "theme": "Modern",
    "save_workspace": "never",
    "always_save_history": false,
    "posix_terminal_shell": "bash",
} 
EOF

COPY rstudio_scripts/install.sh /rstudio_scripts/install.sh
COPY rstudio_scripts/oncreate.sh /rstudio_scripts/oncreate.sh
RUN /rstudio_scripts/install.sh

EXPOSE 8787

CMD ["sudo", "-u", "docker", "rserver", "--server-daemonize=0"]
