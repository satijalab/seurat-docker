#!/usr/bin/env Rscript

if (!requireNamespace("rcmdcheck", quietly = TRUE)) {
    install.packages("rcmdcheck")
}

rcmdcheck::rcmdcheck(
    args = c("--no-manual", "--as-cran"), 
    build_args = "--no-manual", 
    error_on = "warning"
)
