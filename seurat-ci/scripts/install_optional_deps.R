#!/usr/bin/env Rscript

if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}

remotes::install_deps(dependencies = c("Suggests", "Enhances"))
