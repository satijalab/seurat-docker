#!/usr/bin/env r
#
# A simple script to install _all_ dependencies.

## load docopt and remotes (or devtools) from CRAN
suppressMessages({
    library(docopt)               # we need docopt (>= 0.3) as on CRAN
    library(remotes)              # or can use devtools as a fallback
})

## configuration for docopt
doc <- "Usage: installAll.r [-h] [-x] [ARGS]

-h --help         Show this help text
-x --usage        Show help and short example usage
"

opt <- docopt(doc)			# docopt parsing

if (opt$usage) {
    cat(doc, "\n\n")
    cat("

Basic usage:

  installAllDeps.r .
  installAllDeps.r somePackage_1.2.3.tar.gz

This script is essentially identical to installDeps.r except that is always
installs all package dependencies, including those listed under 'Enhances'.
See https://dirk.eddelbuettel.com/code/littler.html for more information.\n")
    q("no")
}

if (length(opt$ARGS) == 0 && file.exists("DESCRIPTION") && file.exists("NAMESPACE")) {
    ## we are in a source directory, so build it
    message("* Installing *source* package found in current working directory ...")
    opt$ARGS <- "."
}

## all dependency types
deps <- c("Depends", "Imports", "Suggests", "LinkingTo", "Enhances")

## ensure installation is stripped
Sys.setenv("_R_SHLIB_STRIP_"="true")

invisible(sapply(opt$ARGS, function(r) install_deps(r, dependencies = deps)))
