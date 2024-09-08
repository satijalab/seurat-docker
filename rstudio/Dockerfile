FROM rocker/rstudio:4.4.1 AS rocker-rstudio

FROM satijalab/seurat-base AS install-rstudio

ENV CRAN="https://p3m.dev/cran/__linux__/jammy/latest"
ENV LANG=en_US.UTF-8
ENV R_VERSION="4.4.1"
ENV R_HOME="/usr/lib/R"
ENV RSTUDIO_VERSION="2024.04.2+764"
ENV S6_VERSION="v2.1.0.2"
ENV TZ="Etc/UTC"
ENV DEFAULT_USER "seurat-user"

COPY --from=rocker-rstudio /rocker_scripts/default_user.sh /rocker_scripts/default_user.sh
COPY --from=rocker-rstudio /rocker_scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY --from=rocker-rstudio /rocker_scripts/init_userconf.sh /rocker_scripts/init_userconf.sh
COPY --from=rocker-rstudio /rocker_scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY --from=rocker-rstudio /rocker_scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY --from=rocker-rstudio /rocker_scripts/pam-helper.sh /rocker_scripts/pam-helper.sh
RUN /rocker_scripts/install_rstudio.sh

RUN rm -rf rocker_scripts
RUN mv init /usr/local/bin/launch_rstudio

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $DEFAULT_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DEFAULT_USER \
    && chmod 0440 /etc/sudoers.d/$DEFAULT_USER

CMD ["launch_rstudio"]
