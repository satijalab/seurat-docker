#!/usr/bin/env Rscript

if (!requireNamespace("testthat", quietly = TRUE)) {
    install.packages("testthat")
}

devtools::clean_dll()
testthat::test_local()
