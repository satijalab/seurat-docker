#!/usr/bin/env Rscript

parser <- argparse::ArgumentParser()  
parser$add_argument("pkgdir", nargs = "?", default = ".")

args <- parser$parse_args()
pkgdir <- args$pkgdir

devtools::clean_dll(pkgdir)
remotes::install_local(pkgdir, dependencies = FALSE)
