FROM --platform=amd64 rocker/r-ver:latest AS rocker
FROM --platform=amd64 rocker/r2u:jammy

RUN apt-get update \
    && apt-get install -y libhdf5-dev \ 
    && install2.r --repos="https://bnprks.r-universe.dev" BPCells

COPY --from=rocker /rocker_scripts/bin/install2.r /rocker_scripts/bin/install2.r
RUN ln -sf /rocker_scripts/bin/install2.r /usr/local/bin/install2.r

ENV R_HOME="/usr/lib/R"

COPY --from=rocker /rocker_scripts/install_tidyverse.sh /rocker_scripts/install_tidyverse.sh
RUN sed -i '/^strip \/usr\/local\/lib\/R\/site-library\/\*\/libs\/\*\.so$/d' /rocker_scripts/install_tidyverse.sh \
    && /rocker_scripts/install_tidyverse.sh

ENV DEFAULT_USER="docker"
ENV DISABLE_AUTH="true"
ENV ROOT="true"

COPY --from=rocker /rocker_scripts/default_user.sh /rocker_scripts/default_user.sh
COPY --from=rocker /rocker_scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY --from=rocker /rocker_scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY --from=rocker /rocker_scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY --from=rocker /rocker_scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY --from=rocker /rocker_scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

RUN sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

EXPOSE 8787
CMD ["/init"]

COPY --from=rocker /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh

COPY --from=rocker /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh

ENV CTAN_REPO="https://mirror.ctan.org/systems/texlive/tlnet"
ENV PATH="$PATH:/usr/local/texlive/bin/linux"

COPY --from=rocker /rocker_scripts/install_verse.sh /rocker_scripts/install_verse.sh
COPY --from=rocker /rocker_scripts/install_texlive.sh /rocker_scripts/install_texlive.sh
RUN /rocker_scripts/install_verse.sh

COPY --from=rocker /rocker_scripts /rocker_scripts

RUN ln -sf /rocker_scripts/bin/install2.r /usr/local/bin/install2.r

RUN mkdir -p /home/$DEFAULT_USER/.config/rstudio \
    && touch /home/$DEFAULT_USER/.config/rstudio/rstudio-prefs.json \
    && chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/.config/rstudio \
    && cat <<EOF > /home/$DEFAULT_USER/.config/rstudio/rstudio-prefs.json
{
    "save_workspace": "never",
    "always_save_history": false,
    "posix_terminal_shell": "bash",
    "initial_working_directory": "~",
    "editor_theme": "Pastel On Dark"
} 
EOF

RUN apt-get update \
    && apt-get install -y tidy \
    && install2.r plotly V8
