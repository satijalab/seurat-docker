# Dockerfile for the `satijalab/seurat-ci` image, intended for running CI 
# workflows for https://github.com/satijalab/seurat and its related projects
# (e.g. https://github.com/satijalab/seurat-object).

# Use `rocker/r2u` as the base image.
# The r2u Project provides precompiled Ubuntu binaries for all CRAN packages 
# and their BioConductor dependencies accessible via `apt`. With `bspm` enabled, 
# calls to `install.packages` can also take advantage of this configuration. 
# The main advantage of this setup is that installs are faster and more 
# reliable. The downside is that since r2u only makes precompiled binaries 
# available for R-release, this setup is not compatible with any other versions 
# of R. See https://eddelbuettel.github.io/r2u/ for more details.  
FROM rocker/r2u:noble
