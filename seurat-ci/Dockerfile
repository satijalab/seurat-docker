# Dockerfile for the `satijalab/seurat-ci` image, intended for running CI 
# workflows for https://github.com/satijalab/seurat and its related projects
# (e.g. https://github.com/satijalab/seurat-object).

# Use multi-stage builds to make it convenient to copy scripts from the Rocker 
# Project's versioned stack. We can take advantage of the fact that every
# image in the stack comes configured with a complete set of install scripts 
# and just import the smallest image of the bunch, `rocker/r-ver`. See 
# https://rocker-project.org/images/#the-versioned-stack for more details. 
# TODO: consider vendorizing the rocker_scripts/ directy into `seurat-docker`
# and introducing a script to sync the scripts with https://github.com/rocker-org/rocker-versioned2.
FROM rocker/r-ver:latest AS rocker

# Use `rocker/r2u` as the base image.
# The r2u Project provides precompiled Ubuntu binaries for all CRAN packages 
# and their BioConductor dependencies accessible via `apt`. With `bspm` enabled, 
# calls to `install.packages` can also take advantage of this configuration. 
# The main advantage of this setup is that installs are faster and more 
# reliable. The downside is that since r2u only makes precompiled binaries 
# available for R-release, this setup is not compatible with any other versions 
# of R. See https://eddelbuettel.github.io/r2u/ for more details.  
FROM rocker/r2u:noble

# Use install_pandoc.sh from Rocker's versioned stack.
COPY --from=rocker /rocker_scripts/install_pandoc.sh /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_pandoc.sh

# Use install_quarto.sh from Rocker's versioned stack.
COPY --from=rocker /rocker_scripts/install_quarto.sh /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_quarto.sh
