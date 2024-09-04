#!/usr/bin/env Rscript

if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}

devtools::clean_dll()
remotes::install_local(dependencies = FALSE)
