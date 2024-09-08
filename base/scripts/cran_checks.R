#!/usr/bin/env Rscript

parser <- argparse::ArgumentParser()  
parser$add_argument("pkgdir", nargs = "?", default = ".")

args <- parser$parse_args()
pkgdir <- args$pkgdir

devtools::clean_dll(pkgdir)
rcmdcheck::rcmdcheck(
    args = c("--as-cran"), 
    error_on = "warning"
)
