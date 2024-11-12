FROM --platform=amd64 rocker/r-ver:4.1.1 AS rocker
FROM --platform=amd64 rocker/r2u:jammy

ENV R_VERSION="4.4.1"
ENV R_HOME="/usr/lib/R"
ENV TZ="Etc/UTC"

ENV CRAN="https://p3m.dev/cran/__linux__/jammy/latest"
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

COPY --from=rocker /rocker_scripts/install2.r /rocker_scripts/install2.r
RUN ln -sf /rocker_scripts/bin/install2.r /usr/local/bin/install2.r

COPY --from=rocker /rocker_scripts/install_tidyverse.sh /rocker_scripts/install_tidyverse.sh
RUN /rocker_scripts/install_tidyverse.sh

ENV S6_VERSION="v2.1.0.2"
ENV RSTUDIO_VERSION="2024.04.2+764"
ENV DEFAULT_USER="rstudio"

COPY --from=rocker /rocker_scripts/default_user.sh /rocker_scripts/default_user.sh
COPY --from=rocker /rocker_scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY --from=rocker /rocker_scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY --from=rocker /rocker_scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY --from=rocker /rocker_scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY --from=rocker /rocker_scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $DEFAULT_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEFAULT_USER \
    && chmod 0440 /etc/sudoers.d/$DEFAULT_USER

RUN sed -i '/^suppressMessages(bspm::enable())/i\options(bspm.sudo = TRUE)' /lib/R/etc/Rprofile.site

EXPOSE 8787
CMD ["init"]

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

RUN ln -s /init /usr/local/bin/launch_rstudio

RUN apt-get update \
    && apt-get install -y libhdf5-dev \ 
    && install2.r --repos="https://bnprks.r-universe.dev" BPCells
