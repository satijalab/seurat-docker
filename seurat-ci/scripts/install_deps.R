#!/usr/bin/env Rscript

parser <- argparse::ArgumentParser()  
parser$add_argument("pkgdir", nargs = "?", default = ".")
parser$add_argument("-a", "--all", action = "store_true", help = "...")

args <- parser$parse_args()
pkgdir <- args$pkgdir
optional_deps <- args$all

dependencies <- c("Depends", "Imports", "LinkingTo")
if (optional_deps) {
  dependencies <- c(dependencies, c("Suggests", "Enhances"))
}

remotes::install_deps(pkgdir = pkgdir, dependencies = dependencies)
