#!/usr/bin/env Rscript

# Some global variables
PACKAGE <- 'Seurat'
UBUNTU.VERSION <- Sys.getenv('SEURAT_DOCKER_UBUNTU')
if (nchar(x = UBUNTU.VERSION) == 0) {
  UBUNTU.VERSION <- 'xenial'
}

# Some global holding variables
NOT.CRAN <- vector(mode = 'character')

# Check dependencies
required.pkgs <- c('tools', 'httr')
for (pkg in required.pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Please ensure you have the ", pkg, " package installed", call. = FALSE)
  }
}

#' Get a CRAN DB URL
#'
#' @param package Name of package to get URL for
#'
#' @return The CRAN DB URL for \code{package}
#'
#' @examples
#' GetCranDB(package = 'Seurat')
#'
GetCranDB <- function(package) {
  return(paste0('http://crandb.r-pkg.org/', package, '/all'))
}

#' Get the nearest-created dependencies for a specific package version
#'
#' @param package Name of package
#' @param pkg.version Package version
#'
#' @return ...
#'
#' @importFrom httr GET content
#'
GetNearestDependency <- function(package, pkg.version) {
  pkg.response <- httr::GET(url = GetCranDB(package = package))
  if (pkg.response$status != 200L) {
    stop("")
  }
  pkg.content <- httr::content(x = pkg.response)$versions[[pkg.version]]
  if (is.null(x = pkg.content)) {
    ''
  }
}

pkg.response <- httr::GET(url = GetCranDB(package = PACKAGE))
if (pkg.response$status != 200L) {
  stop("Cannot find CRAN DB entry for ", PACKAGE, call. = FALSE)
}

pkg.content <- httr::content(x = pkg.response)
