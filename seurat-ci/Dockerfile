FROM rocker/rstudio:latest AS rocker-rstudio


FROM rocker/r2u:jammy AS setup-env

RUN apt-get update \
    && RUN apt-get install -y texlive \
    && RUN apt-get install -y texlive-fonts-extra

COPY --from=rocker-rstudio /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh
RUN rm -rf rocker_scripts

COPY --from=rocker-rstudio /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh
RUN rm -rf rocker_scripts


FROM setup-env AS install-bpcells

RUN apt-get update && apt-get install -y libhdf5-dev
RUN Rscript -e 'install.packages("BPCells", repos = "https://bnprks.r-universe.dev")'


CMD ["launch_rstudio"]


FROM install-bpcells AS setup-workspace

RUN Rscript -e 'install.packages(c("argparse", "devtools"))'

COPY tools/install_deps.R /usr/local/bin/r-install-deps
COPY tools/install_pkg.R /usr/local/bin/r-install-pkg
COPY tools/cran_checks.R /usr/local/bin/r-cran-checks
COPY tools/test_pkg.R /usr/local/bin/r-test-pkg


FROM setup-workspace AS install-rstudio

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
