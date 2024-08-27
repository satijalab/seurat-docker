#!/usr/bin/env Rscript

is_installed <- function(pkg) {
    return (requireNamespace(pkg, quietly = TRUE))
}

if (!is_installed("desc")) {
    install.packages("desc")
}

all_deps <- desc::desc_get_deps()

optional_types <- c("Suggests", "Enhances")
optional_deps <- all_deps[all_deps$type %in% optional_types, ]
optional_pkgs <- optional_deps[optional_deps$package != "R", ]$package

pkgs_to_install <- optional_pkgs[!sapply(optional_pkgs, is_installed)]

install.packages(pkgs_to_install)
