#!/usr/bin/env Rscript

if (!requireNamespace("testthat", quietly = TRUE)) {
    install.packages("testthat")
}

testthat::test_local()
