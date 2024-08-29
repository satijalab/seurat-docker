#!/usr/bin/env Rscript

if (!requireNamespace("rcmdcheck", quietly = TRUE)) {
    install.packages("rcmdcheck")
}

rcmdcheck::rcmdcheck(
    args = c("--as-cran"), 
    error_on = "warning"
)
