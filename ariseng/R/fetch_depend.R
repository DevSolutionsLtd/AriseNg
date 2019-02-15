# fetch_dependencies

#' Fetch the packages needed for the exercise
#'
#' Download and install packages required to use this project.
#'
#' @details The function carries out a check as to whether the packages already
#' exist for the current version of R. The packages are:
#' \describe{
#'   \item{\link{\code{gWidgets2}}}
#'   \item{\link{\code{gWidgets2RGtk2}}}
#'   \item{\link{\code{RGtk2}}}
#'   \item{\link{\code{DataEntry}}}
#' }
#'
#' @importFrom utils install.packages
#'
#' @export
fetch_dependencies <- function()
{
  pkgs <- c('gWidgets2', 'gWidgets2RGtk2', 'RGtk2', 'DataEntry')
  absent <- !(pkgs %in% .packages(all.available = TRUE))
  install.packages(pkgs[absent], repos = 'https://cran.rstudio.com', verbose = TRUE)
}
